//
//  UserData.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

class UserData {
    static let shared = UserData()
    
    var userID: String?
//    var emailAddress: String?
//    var fullName: String?
//    var givenName: String?
//    var familyName: String?
//    var profilePicUrl: URL?
    var points: Double?
    var chosenBadge: String?
    var badges: [String?] = Array()
    var timeSinceLastWorkout: TimeInterval?
    var username: String?
    var completedWorkouts: Int?
    var showOnLeaderboards: Bool?
    
    // Prevent external instantiation
    private init() {}
    
    func populate(with user: User) {
        // Populate user information from GIDGoogleUser
        UserData.shared.userID = user.uid
//        UserData.shared.emailAddress = user.profile?.email
//        UserData.shared.fullName = user.profile?.name
//        UserData.shared.givenName = user.profile?.givenName
//        UserData.shared.familyName = user.profile?.familyName
//        UserData.shared.profilePicUrl = user.profile?.imageURL(withDimension: 320)
    }

}
