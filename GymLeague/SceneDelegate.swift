//
//  SceneDelegate.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            let window = UIWindow(windowScene: windowScene)

            if let user = user {
                // Populate UserData
                UserData.shared.emailAddress = user.profile?.email
                UserData.shared.fullName = user.profile?.name
                UserData.shared.givenName = user.profile?.givenName
                UserData.shared.familyName = user.profile?.familyName
                UserData.shared.profilePicUrl = user.profile?.imageURL(withDimension: 320)
                UserData.shared.userID = user.userID

                // Show the app's signed-in state after UserData is populated
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBar")
            } else {
                // Handle error or signed-out state
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window.rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
            }

            self.window = window
            window.makeKeyAndVisible()
        }
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

