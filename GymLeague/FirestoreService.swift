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
                    "timestamp": Date().timeIntervalSince1970
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
    
    func checkWhitelistRequest(for place: Place, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("gym_whitelist_requests")
        let query = collectionRef.whereField("name", isEqualTo: place.name)
                                .whereField("latitude", isEqualTo: place.coordinate.latitude)
                                .whereField("longitude", isEqualTo: place.coordinate.longitude)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error checking whitelist requests: \(error)")
                completion(false)
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Place has a whitelist request
                completion(true)
            } else {
                // Place does not have a whitelist request
                completion(false)
            }
        }
    }
    
    func isGymWhitelisted(gym: Place, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("whitelisted_gyms")
        let query = collectionRef.whereField("name", isEqualTo: gym.name)
                                .whereField("latitude", isEqualTo: gym.coordinate.latitude)
                                .whereField("longitude", isEqualTo: gym.coordinate.longitude)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error checking whitelisted gyms: \(error)")
                completion(false)
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Gym is whitelisted
                completion(true)
            } else {
                // Gym is not whitelisted
                completion(false)
            }
        }
    }
}
