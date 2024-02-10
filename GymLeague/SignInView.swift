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
        //updateSignInButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Determine what the new text will be after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // Check if the email field is being edited and if the password field meets the requirements
        if textField == emailTextField {
            signInButton.isEnabled = !updatedText.isEmpty && (passwordTextField.text?.count ?? 0) >= 6
        }
        // Check if the password field is being edited and if the email field is non-empty
        else if textField == passwordTextField {
            let isPasswordValid = updatedText.count >= 6
            signInButton.isEnabled = isPasswordValid && !(emailTextField.text?.isEmpty ?? true)
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
        self.fullEmailSignIn(returningUser: false, email: emailTextField.text!, password: passwordTextField.text!) { success in
            if success {
                print("Signed Up successfully")
                Config.shared.showMainTabBarController()
            } else {
                print("Sign up failed")
            }
        }
    }
    
    @objc func returningUserAction() {
        // Handle returning user sign-in
        print("Handle Returning User Sign-In")
        self.fullEmailSignIn(returningUser: true, email: emailTextField.text!, password: passwordTextField.text!) { success in
            if success {
                print("Returned User successfully")
                Config.shared.showMainTabBarController()
            } else {
                print("Sign in failed")
            }
        }
    }

    func fullEmailSignIn(returningUser: Bool, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // When some action occurs, notify the delegate
        delegate?.fullEmailSignIn(returningUser: returningUser, email: email, password: password) { success in
            completion(success)
        }
    }
    
}

protocol SignInViewDelegate: AnyObject {
    func fullEmailSignIn(returningUser: Bool, email: String, password: String, completion: @escaping (Bool) -> Void)
}
