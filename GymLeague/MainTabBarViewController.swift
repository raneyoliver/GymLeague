//
//  MainTabBarViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/13/24.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        tabBarController?.tabBar.backgroundImage = nil
        tabBarController?.tabBar.shadowImage = nil
        tabBarController?.tabBar.backgroundColor = nil
        tabBarController?.tabBar.isTranslucent = true

        tabBarController?.tabBar.backgroundColor = .clear
    }
    
}
