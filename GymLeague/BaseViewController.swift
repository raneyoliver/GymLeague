//
//  BaseViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/6/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundBasedOnAppearance()
    }
    
    private func setBackgroundBasedOnAppearance() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        
        // Check the current user interface style
        if traitCollection.userInterfaceStyle == .dark {
            // Use the dark mode background image
            backgroundImage.image = UIImage(named: "GLBGdark")
        } else {
            // Use the light mode background image
            backgroundImage.image = UIImage(named: "GLBG")
        }
        
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBackgroundBasedOnAppearance()
    }
}

