//
//  LaunchScreenViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/30/23.
//

import UIKit
import GoogleSignIn

class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("sign-in button tapped")
        signIn() {
            // Assuming sign-in was successful if no error
            print("Sign-in successful")
            self.showMainTabBarController()
        }
    }
    
    func signIn(completion: @escaping () -> Void) {
        print("attempting to sign-in")
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                // Handle sign-in errors
                print("Sign-in failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    strongSelf.showErrorAlert(message: error.localizedDescription)
                }
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
            
            // Call completion handler indicating that UserData is populated and sign-in is complete
            DispatchQueue.main.async {
                completion()
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
