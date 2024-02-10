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
    
    func fullEmailSignIn(returningUser: Bool, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Prompt for username
        AuthenticationService.shared.promptForUsername(viewController: self) { (username: String?) in
            guard let username = username else {
                completion(false)
                return
            }

            UserData.shared.username = username

            AuthenticationService.shared.attemptEmailSignIn(returningUser: returningUser, email: email, password: password) { (authResult: AuthDataResult?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }

                guard let user = authResult?.user else {
                    completion(false)
                    return
                }

                AuthenticationService.shared.signIn(user: user) { (error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                        return
                    }

                    AuthenticationService.shared.ensureUserOnLeaderboard(viewController: self) { (success: Bool) in
                        completion(success)
                    }
                }
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
