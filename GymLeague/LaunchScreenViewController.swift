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
            UserData.shared.userID = user.userID
            
            // Add leaderboard entry
            strongSelf.addLeaderboardEntry(userID: UserData.shared.userID ?? "errorUserID", name: UserData.shared.givenName ?? "errorName", points: UserData.shared.points ?? -1.0) { success in
                // Check if leaderboard entry was successful
                if success {
                    // Now, call completion handler
                    DispatchQueue.main.async {
                        completion()
                    }
                } else {
                    // Handle failure to add leaderboard entry
                    print("Failed to add leaderboard entry.")
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
    
    func addLeaderboardEntry(userID: String, name: String, points: Double, completion: @escaping (Bool) -> Void) {
        print("attempting to add leaderboard entry")
        // Reference to the collection
        let leaderboardRef = db.collection("leaderboards")
        
        // Check for existing document with the same idToken
        leaderboardRef.whereField("userID", isEqualTo: userID).getDocuments { [weak self] (querySnapshot, err) in
            guard self != nil else {
                print("Test")
                return
                
            }
            
            // Handle errors from the query
            if let err = err {
                print("Error checking for existing leaderboard entry: \(err)")
                return
            }
            
            // Check if any documents are found
            if true {
//            if let existingDocs = querySnapshot?.documents, existingDocs.isEmpty {
                // No existing document with the same idToken, proceed to add new document
                let badges = ["beta", "new"]
                // Document data
                let leaderboardData: [String: Any] = [
                    "userID": userID,
                    "name": name,
                    "points": points,
                    "badges": badges,
                    "chosenBadge": badges.randomElement()!
                ]
                
                // Add a new document with a generated ID
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        print("Document added with ID: \(userID), welcome to my app, \(name)!")
                        completion(true)
                    }
                }
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        print("Document added with ID: \(userID), welcome to my app, \(name)!")
                        completion(true)
                    }
                }
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        print("Document added with ID: \(userID), welcome to my app, \(name)!")
                        completion(true)
                    }
                }
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        print("Document added with ID: \(userID), welcome to my app, \(name)!")
                        completion(true)
                    }
                }
                leaderboardRef.addDocument(data: leaderboardData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false)
                    } else {
                        print("Document added with ID: \(userID), welcome to my app, \(name)!")
                        completion(true)
                    }
                }
            } else {
                // Existing document found with the same idToken, don't insert new document
                print("A leaderboard entry already exists for this user.")
                completion(true)
            }
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
