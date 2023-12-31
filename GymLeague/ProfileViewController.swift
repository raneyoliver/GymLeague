//
//  ProfileViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let emailAddress = UserData.shared.emailAddress
//        let givenName = UserData.shared.givenName
//        let familyName = UserData.shared.familyName
        
        let fullName = UserData.shared.fullName
        if let profilePicUrl = UserData.shared.profilePicUrl {
            imageView.loadImage(from: profilePicUrl)
        }
        
        // Update UI elements with the user data
        nameLabel.text = fullName
        makeImageViewCircular(imageView: imageView)
    }
    
    func makeImageViewCircular(imageView: UIImageView) {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
        }
    
    @IBAction func signOut(sender: Any) {
        // Create the alert controller
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        // Add a "Yes" action to sign out
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            // Perform the sign out
            GIDSignIn.sharedInstance.signOut()
            
            // Update the UI as necessary, maybe go back to the login screen or update the current view
            self.showSignInViewController()
        }))
        
        // Add a "No" action to cancel
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func showSignInViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            window.rootViewController = signInViewController
            window.makeKeyAndVisible()
        }
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

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                // Set image data here
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
