//
//  UserData.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import Foundation
import GoogleSignIn

class UserData {
    static let shared = UserData()
    
    var userID: String?
    var emailAddress: String?
    var fullName: String?
    var givenName: String?
    var familyName: String?
    var profilePicUrl: URL?
    var points: Double?
    var chosenBadge: String?
    var badges: [String?] = Array()
    var timeSinceLastWorkout: TimeInterval?
    
    // Prevent external instantiation
    private init() {}
    
    func populate(with user: GIDGoogleUser) {
        // Populate user information from GIDGoogleUser
        UserData.shared.userID = user.userID
        UserData.shared.emailAddress = user.profile?.email
        UserData.shared.fullName = user.profile?.name
        UserData.shared.givenName = user.profile?.givenName
        UserData.shared.familyName = user.profile?.familyName
        UserData.shared.profilePicUrl = user.profile?.imageURL(withDimension: 320)
    }
    
    func updateLeaderboardInfo(with data: [String: Any]) {
        // Update leaderboard related information
        UserData.shared.badges = data["badges"] as! [String?]
        UserData.shared.chosenBadge = data["chosenBadge"] as? String? ?? "default"
        UserData.shared.points = data["points"] as? Double
    }
}
