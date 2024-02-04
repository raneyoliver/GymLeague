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
    }
    
    func setupFirebaseSignIn() {
        guard let authUI = FUIAuth.defaultAuthUI() else { return }
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
        
        let providers: [FUIAuthProvider] = [
            //FUIEmailAuth(),
            FUIGoogleAuth(authUI: authUI),
        ]
        authUI.providers = providers

        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true)
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
      return CustomAuthPickerViewController(authUI: authUI)
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
                        Config.shared.showMainTabBarController()
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
        AuthenticationService.shared.manualSignIn(user: user) { error in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                Config.shared.showMainTabBarController()
            }
        }
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

    
    @IBAction func signInButtonTapped(_ sender: Any) {
        setupFirebaseSignIn()
    }
    
    // Helper function to show error message
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
}
