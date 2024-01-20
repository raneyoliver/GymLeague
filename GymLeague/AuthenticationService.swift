//
//  AuthenticationService.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/3/24.
//

import Foundation
import GoogleSignIn
import FirebaseFirestore

class AuthenticationService {
    static let shared = AuthenticationService()
    
    var disallowedWords:[String]!
    
    private init() {}  // Private constructor to ensure singleton usage
    
    func signIn(withPresenting presentingVC: UIViewController, completion: @escaping (Error?) -> Void) {
        print("attempting to sign-in")
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] signInResult, error in
            guard self != nil else { return }
            
            if let error = error {
                // Handle sign-in errors
                print("Sign-in failed with error: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            
            // Store user data
            UserData.shared.emailAddress = user.profile?.email
            UserData.shared.fullName = user.profile?.name
            UserData.shared.givenName = user.profile?.givenName
            UserData.shared.familyName = user.profile?.familyName
            UserData.shared.profilePicUrl = user.profile?.imageURL(withDimension: 320)
            UserData.shared.userID = user.userID
            
            // Fetch or add leaderboard entry based on the sign-in result
            LeaderboardService.shared.fetchLeaderboardEntry(forUserID: user.userID!) { data, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching leaderboard entry: \(error.localizedDescription)")
                        // Assume new user; handle accordingly
                        LeaderboardService.shared.handleNewUser()
                    } else if let data = data {
                        // Existing user; update local user data
                        LeaderboardService.shared.updateUserData(with: data.data())
                    } else {
                        print("No leaderboard data found for the user; adding new entry")
                        LeaderboardService.shared.handleNewUser()
                    }
                    completion(nil)  // Call completion in all cases
                }
            }
        }
    }

    func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?, Error?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            completion(user, error)
        }
    }
    
    func promptForUsername(viewController: UIViewController, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Set Username", message: "Username must be between 3 and 16 characters and cannot include special characters or spaces.", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alertController] _ in
            guard let strongSelf = self, let alertController = alertController else {
                print("can't initiate alertcontroller")
                return
            }
            
            if let username = alertController.textFields?.first?.text, !username.isEmpty {
                strongSelf.validateAndCheckUsername(username) { isValid in
                    if isValid {
                        completion(username) // Pass the valid username
                    } else {
                        strongSelf.showInvalidUsernameAlert(viewController: viewController)
                        strongSelf.promptForUsername(viewController: viewController, completion: completion) // Re-prompt for username
                    }
                }
            } else {
                strongSelf.promptForUsername(viewController: viewController, completion: completion) // Re-prompt if empty
            }
        }
        confirmAction.isEnabled = false

        alertController.addTextField { textField in
            textField.placeholder = "Username"
            textField.textDidChangeAction = { [weak self] text in
                guard let self = self else { return }
                let isTextValid = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                                  self.isUsernameValid(text)
                confirmAction.isEnabled = isTextValid
            }
        }

        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion(nil) }))

        viewController.present(alertController, animated: true)
    }

    func isUsernameValid(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9]{3,16}$" // Alphanumeric characters, 3 to 16 characters in length
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: username)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let alertController = sender.superview?.superview as? UIAlertController,
              let confirmAction = alertController.actions.first(where: { $0.title == "Confirm" }) else {
            return
        }
        
        let text = sender.text ?? ""
        confirmAction.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func showInvalidUsernameAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: "Invalid Username", message: "Username must be alphanumeric, between 3 and 16 characters, and cannot include special characters or spaces.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }


    func validateAndCheckUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        if isUsernameInappropriate(username) {
            completion(false) // Username is inappropriate
            return
        }
        
        let db = Firestore.firestore()
        db.collection("leaderboards").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking username: \(error)")
                completion(false) // Handle error appropriately
            } else if let snapshot = snapshot, snapshot.documents.isEmpty {
                completion(true) // Username is available
            } else {
                completion(false) // Username already exists
            }
        }
    }

    func isUsernameInappropriate(_ username: String) -> Bool {
        // List of disallowed words
        disallowedWords = loadProfanityWords()

        for word in disallowedWords {
            if username.lowercased().contains(word) {
                return true
            }
        }
        return false
    }

    func loadProfanityWords() -> [String] {
        var profanityWords: [String] = []

        // Get the path for the 'username_filters' folder
        guard let folderPath = Bundle.main.path(forResource: "username_filters", ofType: nil) else {
            print("Folder not found.")
            return profanityWords
        }

        do {
            // List all files in the folder
            let fileURLs = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: folderPath), includingPropertiesForKeys: nil)

            for fileURL in fileURLs {
                if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                    // Split the content into lines and add them to the array
                    profanityWords.append(contentsOf: content.split(whereSeparator: \.isNewline).map(String.init))
                }
            }
        } catch {
            print("Error reading folder contents: \(error)")
        }

        return profanityWords
    }

}

// Extend UITextField to hold a closure for text change
private extension UITextField {
    typealias TextDidChangeAction = (String) -> Void

    struct Holder {
        static var textDidChangeAction: TextDidChangeAction?
    }

    var textDidChangeAction: TextDidChangeAction? {
        get {
            return Holder.textDidChangeAction
        }
        set(newValue) {
            Holder.textDidChangeAction = newValue
            addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        }
    }

    @objc func textFieldTextDidChange() {
        textDidChangeAction?(self.text ?? "")
    }
}

