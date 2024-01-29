//
//  FirestoreService.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/19/24.
//

import FirebaseFirestore
import CoreLocation

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func storeWhitelistRequest(for place: Place, completion: @escaping (Bool, Error?) -> Void) {
        let collectionRef = db.collection("gym_whitelist_requests")
        let query = collectionRef.whereField("name", isEqualTo: place.name)
                                .whereField("latitude", isEqualTo: place.coordinate.latitude)
                                .whereField("longitude", isEqualTo: place.coordinate.longitude)

        // Check for duplicates
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(false, error)
                return
            }

            if let snapshot = snapshot, snapshot.documents.isEmpty {
                // No duplicate found, proceed to add the request
                let requestData: [String: Any] = [
                    "name": place.name,
                    "latitude": place.coordinate.latitude,
                    "longitude": place.coordinate.longitude,
                    "timestamp": Date().timeIntervalSince1970,
                    "status": "pending"
                ]

                collectionRef.addDocument(data: requestData) { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                // Duplicate exists, do not add
                completion(false, nil)
            }
        }
    }
    
    func checkWhitelistStatus(for place: Place, completion: @escaping (String) -> Void) {
        let collectionRef = db.collection("gym_whitelist_requests")
        let query = collectionRef.whereField("name", isEqualTo: place.name)
                                .whereField("latitude", isEqualTo: place.coordinate.latitude)
                                .whereField("longitude", isEqualTo: place.coordinate.longitude)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error checking whitelist requests: \(error)")
                completion("")
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Place has a whitelist request
                let status = (snapshot.documents.first?["status"] ?? "") as? String
                completion(status!)
            } else {
                // Place does not have a whitelist request
                completion("none")
            }
        }
    }
    
    func updateLeaderboardBadges(forUserID userID: String) {
        let collectionRef = db.collection("leaderboards")
        let query = collectionRef.whereField("userID", isEqualTo: userID)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error finding user document: \(error)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("User document not found.")
                return
            }

            guard let points = document.data()["points"] as? Double else {
                print("Points field is missing or not a double.")
                return
            }
            
            var newBadges: [String] = document.data()["badges"] as? [String] ?? []
                
            // Check and add badges based on points
            for section in sections {
                if let section = section {
                    if points >= section.minPoints {
                        if !newBadges.contains(section.name) {
                            newBadges.append(section.name)
                        }
                    }
                }
            }

            // Update the document
            document.reference.updateData(["badges": newBadges]) { err in
                if let err = err {
                    print("Error updating badges: \(err)")
                } else {
                    print("Badges successfully updated.")
                }
            }
        }
    }
    
    func canUserStartWorkout(for userId: String, completion: @escaping (Bool, Error?) -> Void) {
        let completedWorkoutsRef = db.collection("completed_workouts").whereField("userID", isEqualTo: userId)

        completedWorkoutsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("error getting completed_workouts")
                completion(false, error)
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                // If there are no documents, the user hasn't completed any workouts
                //print(userId)
                //print(snapshot?.documents ?? ":")
                print("no completed_workouts for this user found")
                completion(true, nil)
                return
            }

            // Get the most recent workout
            if let mostRecentWorkout = documents.max(by: {
                ($0.data()["date"] as? TimeInterval ?? 0) < ($1.data()["date"] as? TimeInterval ?? 0)
            }), let timeSinceLastWorkout = mostRecentWorkout.data()["date"] as? TimeInterval {
                // Check if 24 hours have passed since the last workout
                let lastWorkoutDate = Date(timeIntervalSince1970: timeSinceLastWorkout)
                let currentDate = Date()
                let twentyFourHoursAgo = currentDate.addingTimeInterval(-24 * 60 * 60)

                print("24 passed?: \(lastWorkoutDate < twentyFourHoursAgo)")
                completion(lastWorkoutDate < twentyFourHoursAgo, nil) // More than 24 hours have passed
            } else {
                // Error handling if date is not found
                completion(false, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error retrieving date from last workout"]))
            }
        }
    }
    
    func addCompletedWorkout(for userId: String, username: String, newPoints: Double, completion: @escaping (Bool) -> Void) {
        // Prepare data
        let workoutData: [String: Any] = [
            "userID": userId,
            "username": username,
            "points": newPoints,
            "date": Int(Date().timeIntervalSince1970) // Current date as Unix timestamp
        ]

        // Add a new document to the completed_workouts collection
        db.collection("completed_workouts").addDocument(data: workoutData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(false)
            } else {
                print("Document added successfully")
                // Increment completedWorkouts in the leaderboards collection
                self.incrementCompletedWorkouts(for: userId)
                completion(true)
            }
            
            
        }
        
    }
    
    func incrementCompletedWorkouts(for userId: String) {
        let query = db.collection("leaderboards").whereField("userID", isEqualTo: userId)

        // Fetch the document with the matching userID
        query.getDocuments { [weak self] (snapshot, error) in
            guard let document = snapshot?.documents.first else {
                if let error = error {
                    print("Error fetching document: \(error)")
                } else {
                    print("Document with userID \(userId) not found.")
                }
                return
            }

            // Atomically increment the completedWorkouts field by 1
            self?.db.collection("leaderboards").document(document.documentID).updateData([
                "completedWorkouts": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error updating completedWorkouts: \(error)")
                } else {
                    print("Successfully incremented completedWorkouts")
                }
            }
        }
    }
}
