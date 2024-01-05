//
//  AuthenticationService.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/3/24.
//

import Foundation
import GoogleSignIn

class AuthenticationService {
    static let shared = AuthenticationService()
    
    private init() {}  // Private constructor to ensure singleton usage
    
    func signIn(withPresenting presentingVC: UIViewController, completion: @escaping (Error?) -> Void) {
        print("attempting to sign-in")
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] signInResult, error in
            guard self != nil else { return }
            
            if let error = error {
                // Handle sign-in errors
                print("Sign-in failed with error: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            
            // Store user data
            UserData.shared.emailAddress = user.profile?.email
            UserData.shared.fullName = user.profile?.name
            UserData.shared.givenName = user.profile?.givenName
            UserData.shared.familyName = user.profile?.familyName
            UserData.shared.profilePicUrl = user.profile?.imageURL(withDimension: 320)
            UserData.shared.userID = user.userID
            
            // Fetch or add leaderboard entry based on the sign-in result
            LeaderboardService.shared.fetchLeaderboardEntry(forUserID: user.userID!) { data, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching leaderboard entry: \(error.localizedDescription)")
                        // Assume new user; handle accordingly
                        LeaderboardService.shared.handleNewUser()
                    } else if let data = data {
                        // Existing user; update local user data
                        LeaderboardService.shared.updateUserData(with: data.data())
                    } else {
                        print("No leaderboard data found for the user; adding new entry")
                        LeaderboardService.shared.handleNewUser()
                    }
                    completion(nil)  // Call completion in all cases
                }
            }
        }
    }

    func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?, Error?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            completion(user, error)
        }
    }
}
