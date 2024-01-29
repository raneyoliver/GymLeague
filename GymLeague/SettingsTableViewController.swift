//
//  SettingsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/7/24.
//

import UIKit
import GoogleSignIn
import FirebaseAuthUI

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsHeaderView.self, forHeaderFooterViewReuseIdentifier: "SettingsHeaderView")
        
        self.view.backgroundColor = CustomBackgroundView.color
    }

    func signOut(sender: Any) {
        // Create the alert controller
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        // Add a "Yes" action to sign out
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            // Perform the sign out
            let authUI = FUIAuth.defaultAuthUI()
            do {
                try authUI!.signOut() //signOut(sender: self)
                self.showSignInViewController()
            } catch {
                print(error)
            }
            //GIDSignIn.sharedInstance.signOut()
        }))
        
        // Add a "No" action to cancel
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func showSignInViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            window.rootViewController = signInViewController
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 1 ? 0 : 1 // Assuming section 0 is your main section
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        cell.backgroundColor = CustomBackgroundView.oneAboveColor
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        // Configure your cell
        if indexPath.row == 0 {
            cell.textLabel?.text = "Sign Out"
        }
        
        
        // Set the disclosure indicator
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Determine the cell that was tapped and perform an action
            switch indexPath.section {
                case 0:  // For section 0
                    switch indexPath.row {
                        case 0:
                        signOut(sender: self)
                        // Add more cases as needed for each cell
                        default: break
                    }
                // Add more cases for additional sections
                default: break
            }
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingsHeaderView") as! SettingsHeaderView
        headerView.delegate = self  // SettingsTableViewController is now the delegate
        tableView.tableHeaderView = headerView
        
//        headerView.layer.borderWidth = 3
//        headerView.layer.borderColor = UIColor.systemBlue.cgColor
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 0 : 60 // or whatever height your header should be
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}

extension SettingsTableViewController: SettingsHeaderViewDelegate {
    func didTapReturnButton() {
        dismiss(animated: true, completion: nil)
    }
}
