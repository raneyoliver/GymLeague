//
//  LeaderboardsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import FirebaseFirestore

struct LeaderboardEntry {
    var rank: Int
    var name: String
    var points: Int
    var division: String
}


class LeaderboardsTableViewController: UITableViewController {

    var db: Firestore!
    var leaderboardEntries = [LeaderboardEntry]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Initialize Firestore
        db = Firestore.firestore()
        
        readLeaderboard()
    }

    // Reading leaderboard data
    func readLeaderboard() {
            db.collection("leaderboards").order(by: "rank").getDocuments { [weak self] (querySnapshot, err) in
                guard let self = self else { return }
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.leaderboardEntries.removeAll()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let entry = LeaderboardEntry(
                            rank: data["rank"] as? Int ?? 0,
                            name: data["name"] as? String ?? "",
                            points: data["points"] as? Int ?? 0,
                            division: data["division"] as? String ?? "")
                        self.leaderboardEntries.append(entry)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.leaderboardEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)

        let entry = leaderboardEntries[indexPath.row]
        // Configure your cell with the entry data
        cell.textLabel?.text = "\(entry.rank). \(entry.name) - \(entry.division) - \(entry.points)pts"

        return cell
    }

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
