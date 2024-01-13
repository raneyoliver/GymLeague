//
//  PointsService.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/11/24.
//

import FirebaseFirestore
import Foundation

class PointsService {
    static let shared = PointsService()
    private let db = Firestore.firestore()
    private let pointsPerWorkout: Double = 10
    private let oneWeekInSeconds: Double = 604800  // Number of seconds in one week
    private let oneDayInSeconds: Double = 86400    // Number of seconds in one day

    private init() {}

    func awardPoints(forUserID userID: String, completion: @escaping (Bool) -> Void) {
        let leaderboardQuery = db.collection("leaderboards").whereField("userID", isEqualTo: userID)

        leaderboardQuery.getDocuments { querySnapshot, error in
            guard let document = querySnapshot?.documents.first else {
                completion(false)
                return
            }

            var points = document.data()["points"] as? Double ?? 0
            points += self.pointsPerWorkout
            UserData.shared.points = points
            let currentTime = Date().timeIntervalSince1970

            document.reference.updateData(["points": points, "timeSinceLastWorkout": currentTime]) { error in
                completion(error == nil)
            }
        }
    }


    /// decay_points runs once per day on GCloud
}
