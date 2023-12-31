//
//  UserData.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import Foundation

class UserData {
    static let shared = UserData()

    var emailAddress: String?
    var fullName: String?
    var givenName: String?
    var familyName: String?
    var profilePicUrl: URL?

    // Prevent external instantiation
    private init() {}
}
