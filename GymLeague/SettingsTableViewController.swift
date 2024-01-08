//
//  SettingsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/7/24.
//

import UIKit
import GoogleSignIn

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
            GIDSignIn.sharedInstance.signOut()
            
            // Update the UI as necessary, maybe go back to the login screen or update the current view
            self.showSignInViewController()
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
                        case 0: signOut(sender: self)
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
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//
//        // Assuming the title starts getting revealed after 50 points of scrolling
//        let startRevealOffset: CGFloat = 50
//        let revealDistance: CGFloat = 30 // over how many points of scrolling the title will fully appear
//
//        // Calculate the alpha based on the scroll position
//        var alpha: CGFloat = 0
//        if offsetY > startRevealOffset {
//            alpha = min((offsetY - startRevealOffset) / revealDistance, 1)
//        } else {
//            alpha = 1
//        }
//
//        // Get the header view for the relevant section
//        if let header = tableView.headerView(forSection: 0) as? SettingsHeaderView {
//            header.titleLabel.alpha = alpha
//        }
//    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsTableViewController: SettingsHeaderViewDelegate {
    func didTapReturnButton() {
        dismiss(animated: true, completion: nil)
    }
}
