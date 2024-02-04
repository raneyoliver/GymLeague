//
//  SignInView.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/3/24.
//

import Foundation
import UIKit
import FirebaseAuth

class SignInView: UIView, UITextFieldDelegate {
    
    weak var delegate: SignInViewDelegate?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        if let view = Bundle.main.loadNibNamed("SignInView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            addSubview(view)
            
            setupSegmentedControl()
            errorLabel.numberOfLines = 0
            signInButton.isEnabled = false
            emailTextField.delegate = self
            passwordTextField.delegate = self
            emailTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
            passwordTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        }
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        updateSignInButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Determine what the new text will be after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // Enable signInButton if both text fields are non-empty, disable otherwise
        if textField == emailTextField {
            signInButton.isEnabled = !updatedText.isEmpty && !(passwordTextField.text?.isEmpty ?? true)
        } else if textField == passwordTextField {
            signInButton.isEnabled = !updatedText.isEmpty && !(emailTextField.text?.isEmpty ?? true)
        }

        return true
    }

    func updateSignInButtonState() {
        signInButton.isEnabled = !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
    }
    
    func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = self.backgroundColor
        
        signInButton.addTarget(self, action: #selector(returningUserAction), for: .touchUpInside)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            self.errorLabel.text = ""
            if sender.selectedSegmentIndex == 1 {
                // "New User" is selected
                self.signInButton.setTitle("Create account", for: .normal)
                self.signInButton.removeTarget(nil, action: nil, for: .allEvents)
                self.signInButton.addTarget(self, action: #selector(self.newUserAction), for: .touchUpInside)
            } else {
                // "Returning User" is selected
                self.signInButton.setTitle("Sign in", for: .normal)
                self.signInButton.removeTarget(nil, action: nil, for: .allEvents)
                self.signInButton.addTarget(self, action: #selector(self.returningUserAction), for: .touchUpInside)
            }
        }
        
    }
    
    @objc func newUserAction() {
        // Handle new user sign-up
        print("Handle New User Sign-Up")
        self.attemptEmailSignIn(returningUser: false, email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    @objc func returningUserAction() {
        // Handle returning user sign-in
        print("Handle Returning User Sign-In")
        self.attemptEmailSignIn(returningUser: true, email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    func attemptEmailSignIn(returningUser: Bool, email: String, password: String) {
        if returningUser {
            // Attempt to sign in for returning users
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    // Handle sign-in errors
                    print("Error attempting email sign in: \(error.localizedDescription)")
                    self.errorLabel.text = error.localizedDescription
                } else {
                    print("Returning user signed in successfully")
                    // Handle successful sign-in
                    self.handleSuccessfulSignIn(authResult: authResult)
                }
            }
        } else {
            // Attempt to create a new user for new users
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    if AuthErrorCode.Code(rawValue: error.code) == .emailAlreadyInUse {
                        // Handle error if the email is already in use
                        print("Email already in use, cannot create new user.")
                    } else {
                        // Handle other errors
                        print("Error attempting to create new user: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self.errorLabel.text = error.localizedDescription
                    }
                    
                } else {
                    print("New user created and signed in successfully")
                    // Handle successful account creation and sign-in
                    self.handleSuccessfulSignIn(authResult: authResult)
                }
            }
        }
    }

    private func handleSuccessfulSignIn(authResult: AuthDataResult?) {
        // Common sign-in success handling logic
        DispatchQueue.main.async {
            self.errorLabel.text = ""
        }
        
        AuthenticationService.shared.manualSignIn(user: authResult?.user) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Sign-in successful")
                self.useParentVCToEnsureUserOnLeaderboard()
            }
        }
    }

    
    func useParentVCToEnsureUserOnLeaderboard() {
        // When some action occurs, notify the delegate
        delegate?.ensureUserOnLeaderboard()
    }
    
}

protocol SignInViewDelegate: AnyObject {
    func ensureUserOnLeaderboard()
}
