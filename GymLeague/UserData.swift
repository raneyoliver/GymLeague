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


    // Prevent external instantiation
    private init() {}
}
