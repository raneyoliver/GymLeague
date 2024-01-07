//
//  SceneDelegate.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import UIKit
import GoogleSignIn
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = UIColor.systemBlue // Example to set global tint

        AuthenticationService.shared.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }



            if let user = user {
                // User is signed in, populate UserData
                UserData.shared.populate(with: user)

                // Fetch the leaderboard entry for the user
                LeaderboardService.shared.fetchLeaderboardEntry(forUserID: user.userID!) { data, error in
                    if let data = data {
                        // Update UserData with leaderboard info
                        UserData.shared.updateLeaderboardInfo(with: data.data())

                        // Now that UserData is fully populated, show the main interface
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBar")
                            self.window = window
                            window.makeKeyAndVisible()
                            print("sign-in successfully restored")
                        }
                    }
                }
            } else {
                // User is not signed in or there was an error, show login
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    window.rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
                    self.window = window
                    window.makeKeyAndVisible()
                    print("error restoring sign-in")
                }
            }
        }
    }


    func fetchLeaderboardEntry() -> [String:Any] {
        // Ensure userID is available
        guard let userID = UserData.shared.userID else {
            print("UserID not available")
            return [:]
        }

        // Reference to Firestore database and specifically the leaderboards collection
        let db = Firestore.firestore()
        let leaderboardsCollection = db.collection("leaderboards")
        
        var documentData:[String:Any] = [:]
        // Query the collection
        leaderboardsCollection.whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle any errors (e.g., network issues, permissions, etc.)
                print("Error getting documents: \(error)")
            } else {
                // Check if documents are returned
                if let document = querySnapshot?.documents.first {
                    // Assuming 'chosenBadge' is a field in the documents of the "leaderboards" collection
                    documentData = document.data()
                    // Now 'chosenBadge' contains the value, and you can use it as needed
                    // Perform any UI updates or further logic with 'chosenBadge'
                } else {
                    print("No documents found matching userID")
                }
            }
        }
        
        return documentData
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

