//
//  Config.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import Foundation
import UIKit

class Config {
    
    static let shared = Config()
    
    private func valueForAPIKey(named keyname: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "keys", ofType: "plist") else {
            fatalError("Couldn't find file 'keys.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        let value = plist?.object(forKey: keyname) as? String
        return value
    }

    func getGooglePlacesAPIKey() -> String {
        guard let key = valueForAPIKey(named: "GooglePlacesAPIKey") else {
            fatalError("Couldn't find key 'GooglePlacesAPIKey' in 'Keys.plist'.")
        }
        return key
    }
    
    func getGoogleServiceInfoValue(keyName: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'GoogleService-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        return plist?.object(forKey: keyName) as! String
    }
    
    func capitalizeFirstLetter(of text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    func setupBlurEffect(onView parentView: UIView, withStyle style: UIBlurEffect.Style) {
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: style) // Choose style as needed
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        // If you are using Auto Layout, set this property to false
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Add the effect view to the view you want to blur
        parentView.insertSubview(blurEffectView, at: 0)

        blurEffectView.alpha = 0.9
        
        // Constraints for the blurEffectView to cover the entire view
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: parentView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
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
}

