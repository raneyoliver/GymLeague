//
//  LeaderboardService.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/3/24.
//

import Foundation
import FirebaseFirestore

struct LeaderboardEntry {
    var userID: String
    var rank: Int
    var name: String
    var points: Int
    var division: String
    var bgConfig: BackgroundImageConfig
}

class LeaderboardService {
    static let shared = LeaderboardService()

    let db = Firestore.firestore()
    
    private init() {}  // Private constructor to ensure singleton usage

    
    /// Get stats of given user
    func fetchLeaderboardEntry(forUserID userID: String, completion: @escaping (QueryDocumentSnapshot?, Error?) -> Void) {
        let leaderboardsCollection = db.collection("leaderboards")
        
        leaderboardsCollection.whereField("userID", isEqualTo: userID).getDocuments { querySnapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(querySnapshot?.documents.first, nil)
//                completion(nil, nil)
            }
        }
    }

    /// Adds a user by id
    func addLeaderboardEntry(forUserID userID: String, name: String, points: Int, badges: [String?], chosenBadge: String, completion: @escaping (Bool) -> Void) {
        print("attempting to add leaderboard entry")
        
        fetchLeaderboardEntry(forUserID: userID) { document, error in
            guard error == nil else {
                print("Error fetching documents: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            if document == nil {
                // No existing document with the same idToken, proceed to add new document
                let leaderboardData: [String: Any] = [
                    "userID": userID,
                    "name": name,
                    "points": points,
                    "badges": badges,
                    "chosenBadge": chosenBadge
                ]
                
                // Add the new document
                let leaderboardRef = self.db.collection("leaderboards")
            
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
        
                
            } else {
                // Existing document found with the same idToken, don't insert new document
                print("A leaderboard entry already exists for this user.")
                completion(false)
            }
        }
    }
    
    func handleNewUser() {
        // Set default values for a new user
        UserData.shared.badges = ["new"]
        UserData.shared.chosenBadge = "new"
        UserData.shared.points = 0
    }

    func updateUserData(with data: [String: Any]) {
        // Update local user data with the fetched data
        UserData.shared.badges = data["badges"] as? [String?] ?? []
        UserData.shared.chosenBadge = data["chosenBadge"] as? String ?? "default"
        UserData.shared.points = data["points"] as? Int ?? 0
    }

    func updateChosenBadge(forUserID userID: String, chosenBadge: String, completion: @escaping (Bool) -> Void) {
        let leaderboardsCollection = db.collection("leaderboards")
        leaderboardsCollection.whereField("userID", isEqualTo: userID).getDocuments { querySnapshot, error in
            if let document = querySnapshot?.documents.first {
                document.reference.updateData(["chosenBadge": chosenBadge]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        completion(false)
                    } else {
                        // Also update UserData with updated info
                        UserData.shared.chosenBadge = chosenBadge
                        completion(true)
                    }
                }
            } else {
                print("Document not found")
                completion(false)
            }
        }
    }

    func getUserRank(completion: @escaping (Int?, Error?) -> Void) {
            // Reference to the collection
            let leaderboardsCollection = db.collection("leaderboards")

            // Get all documents from the leaderboards collection
            leaderboardsCollection.order(by: "points", descending: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion(nil, NSError(domain: "LeaderboardService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No documents found in leaderboards collection"]))
                    return
                }

                // Find the index (rank) of the document where the userID matches UserData.shared.userID
                if let userID = UserData.shared.userID {
                    for (index, document) in documents.enumerated() {
                        let docUserID = document.data()["userID"] as? String ?? ""
                        if docUserID == userID {
                            // Rank is index + 1 since array is 0-indexed and ranks are typically 1-indexed
                            completion(index + 1, nil)
                            return
                        }
                    }
                    // If user not found in leaderboard
                    completion(nil, NSError(domain: "LeaderboardService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found in leaderboards"]))
                } else {
                    completion(nil, NSError(domain: "LeaderboardService", code: 3, userInfo: [NSLocalizedDescriptionKey: "User ID not available"]))
                }
            }
        }
    
}
