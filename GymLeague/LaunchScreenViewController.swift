//
//  LaunchScreenViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/30/23.
//

import UIKit
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI

class LaunchScreenViewController: UIViewController, FUIAuthDelegate {
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CustomBackgroundView.color
        
        db = Firestore.firestore()
        
        if Auth.auth().currentUser != nil {
            // User is signed in, proceed to the main app interface
            self.restorePreviousSignIn(user: Auth.auth().currentUser)
        }
        
        //setupSignInButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //setupFirebaseSignIn()
    }
    
    func setupFirebaseSignIn() {
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI!.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIGoogleAuth(authUI: authUI!),
        ]
        authUI!.providers = providers
        
        let authViewController = authUI!.authViewController()
        self.present(authViewController, animated: true)
    }
    
    func manualSignIn(user: User?) {
        AuthenticationService.shared.signIn(withPresenting: self, user: user!) { error in
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
    
    func restorePreviousSignIn(user: User?) {

        if let user = user {
            // User is signed in, populate UserData
            UserData.shared.populate(with: user)

            // Fetch the leaderboard entry for the user
            LeaderboardService.shared.fetchLeaderboardEntry(forUserID: user.uid) { data, error in
                if let data = data {
                    // Update UserData with leaderboard info
                    LeaderboardService.shared.updateUserData(with: data.data())

                    // Now that UserData is fully populated, show the main interface
                    DispatchQueue.main.async {
                        self.showMainTabBarController()
                        print("sign-in successfully restored")
                    }
                }
            }
        } else {
            // User is not signed in or there was an error, show login
            DispatchQueue.main.async {
                print("error restoring sign-in")
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let user = user else { return }
        manualSignIn(user: user)
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    func setupSignInButton() {
        signInButton.style = GIDSignInButtonStyle.iconOnly
    }
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("sign-in button tapped")
        setupFirebaseSignIn()
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
                print("ensureUserOnLeaderboard: User already has a leaderboard entry")
                LeaderboardService.shared.updateUserData(with: document!.data())
                completion(true)
            } else {
                // User is new or error occurred, handle accordingly, perhaps adding the user
                
                AuthenticationService.shared.promptForUsername(viewController: self) { username in
                    guard let username = username else {
                        print("Username entry was cancelled")
                        return
                    }
                    
                    UserData.shared.username = username
                    
                    // For new user, add them to leaderboard here
                    // Add a new leaderboard entry for the user
                    LeaderboardService.shared.addLeaderboardEntry(forUserID: UserData.shared.userID!, points: UserData.shared.points!, badges: UserData.shared.badges, chosenBadge: UserData.shared.chosenBadge!, timeSinceLastWorkout: UserData.shared.timeSinceLastWorkout!, username: username, completedWorkouts: UserData.shared.completedWorkouts!) { success in
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
