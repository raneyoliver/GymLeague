//
//  CustomAuthPickerViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/2/24.
//

import UIKit
import FirebaseAuthUI

class CustomAuthPickerViewController: FUIAuthPickerViewController, SignInViewDelegate {

    let signInView = SignInView()
    let orLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = CustomBackgroundView.color

        setupSignInView()
        setupOrLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func ensureUserOnLeaderboard() {
        AuthenticationService.shared.ensureUserOnLeaderboard(viewController: self) { success in
            if success {
                DispatchQueue.main.async {
                    // Now it's safe to show the main tab bar
                    Config.shared.showMainTabBarController()
                }
            } else {
                // Handle error, failed to ensure user on leaderboard
                print("Failed to ensure user on leaderboard")
            }
        }
     }
    
    func setupOrLabel() {
        self.view.addSubview(orLabel)
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orLabel.topAnchor.constraint(equalTo: signInView.bottomAnchor, constant: 32),
            orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        orLabel.text = "-or-"
    }
    
    func setupSignInView() {
        signInView.delegate = self
        view.addSubview(signInView)
        signInView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            signInView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signInView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signInView.heightAnchor.constraint(equalToConstant: 248)
        ])
        
        signInView.backgroundColor = CustomBackgroundView.oneAboveColor
        signInView.layer.cornerRadius = 8
        signInView.clipsToBounds = true
        Config.shared.setupBlurEffect(onView: signInView, withStyle: .regular)
    }
}
