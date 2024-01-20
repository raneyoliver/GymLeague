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
    
}
