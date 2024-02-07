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
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Set the frame to match the parent view (for UILabel, you might want to adjust this to match the label's frame specifically)
        blurEffectView.frame = parentView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // For resizing with orientation changes
        
        // Check the type of the parent view and apply the blur effect accordingly
        if let collectionView = parentView as? UICollectionView {
            setupBlurForCollectionView(collectionView, blurEffectView: blurEffectView)
        } else if let tableView = parentView as? UITableView {
            setupBlurForTableView(tableView, blurEffectView: blurEffectView)
        } else if parentView is UILabel {
            setupBlurForLabel(parentView, blurEffectView: blurEffectView)
        } else {
            // For other types of parent views, insert the blur effect view directly
            parentView.insertSubview(blurEffectView, at: 0)
        }
    }

    func setupBlurForCollectionView(_ collectionView: UICollectionView, blurEffectView: UIVisualEffectView) {
        if collectionView.backgroundView == nil {
            collectionView.backgroundView = UIView(frame: collectionView.bounds)
        }
        collectionView.backgroundView?.addSubview(blurEffectView)
    }

    func setupBlurForTableView(_ tableView: UITableView, blurEffectView: UIVisualEffectView) {
        if tableView.backgroundView == nil {
            tableView.backgroundView = UIView(frame: tableView.bounds)
        }
        tableView.backgroundView?.addSubview(blurEffectView)
    }

    func setupBlurForLabel(_ label: UIView, blurEffectView: UIVisualEffectView) {
        // Insert the blurEffectView behind the label in its parent view
        if let parentView = label.superview {
            parentView.insertSubview(blurEffectView, belowSubview: label)
            
            // Optional: Add constraints to blurEffectView to match label's size and position
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurEffectView.topAnchor.constraint(equalTo: label.topAnchor),
                blurEffectView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
                blurEffectView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
                blurEffectView.bottomAnchor.constraint(equalTo: label.bottomAnchor)
            ])
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
}

