//
//  LaunchScreenViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/30/23.
//

import UIKit
import GoogleSignIn
import FirebaseFirestore

class LaunchScreenViewController: UIViewController {
    
    var db: Firestore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("sign-in button tapped")
        AuthenticationService.shared.signIn(withPresenting: self) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                } else {
                    print("sign-in successful")
                    // Check if the user is new and add them to leaderboard if necessary
                    self.ensureUserOnLeaderboard { success in
                        if success {
                            DispatchQueue.main.async {
                                // Now it's safe to show the main tab bar
                                self.showMainTabBarController()
                            }
                        } else {
                            // Handle error, failed to ensure user on leaderboard
                            print("Failed to ensure user on leaderboard")
                        }
                    }
                }
            }
        }
    }
    
    func ensureUserOnLeaderboard(completion: @escaping (Bool) -> Void) {
        guard let userID = UserData.shared.userID else {
            print("User ID not available")
            completion(false)
            return
        }
        
        // Attempt to fetch the user's leaderboard entry
        LeaderboardService.shared.fetchLeaderboardEntry(forUserID: userID) { document, error in
            if document != nil {
                // User already has a leaderboard entry
                completion(true)
            } else {
                // User is new or error occurred, handle accordingly, perhaps adding the user
                // For new user, add them to leaderboard here
                // Add a new leaderboard entry for the user
                LeaderboardService.shared.addLeaderboardEntry(forUserID: UserData.shared.userID!, name: UserData.shared.givenName!, points: UserData.shared.points!, badges: UserData.shared.badges, chosenBadge: UserData.shared.chosenBadge!) { success in
                    if success {
                        print("New leaderboard entry added for the user.")
                    } else {
                        print("Failed to add a new leaderboard entry.")
                    }
                    completion(success)
                }
            }
        }
    }
    
    
    func showMainTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController,
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            window.rootViewController = mainTabBarController
            window.makeKeyAndVisible()
        }
    }
    
    // Helper function to show error message
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
}
