//
//  LeaderboardsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import FirebaseFirestore
import GoogleSignIn

struct LeaderboardEntry {
    var userID: String
    var rank: Int
    var name: String
    var points: Int
    var division: String
    var bgConfig: BackgroundImageConfig
}

struct BackgroundImageConfig {
    let imageName: String
    let horizontalOffset: CGFloat
    let textColor: UIColor
    let tintColor: UIColor
    // Add any other properties you need to configure for each background image

    // Initialize the structure with the settings for a particular image
    init(imageName: String, horizontalOffset: CGFloat, textColor: UIColor, tintColor: UIColor) {
        self.imageName = imageName
        self.horizontalOffset = horizontalOffset
        self.textColor = textColor
        self.tintColor = tintColor
    }
}

class LeaderboardsTableViewController: UITableViewController {
    
    var db: Firestore!
    var leaderboardEntries = [LeaderboardEntry]()
    var expandedCells = [Bool]()
    
    let expandedHeight:CGFloat = 168
    let normalHeight:CGFloat = 50
    
    // Define the initial query
    lazy var query: Query = db.collection("leaderboards").order(by: "points", descending: true).limit(to: 20)
    
    var lastDocumentSnapshot: DocumentSnapshot?
    
    var isFetchingMore = false
    
    var isMoreDataAvailable = true
    
    var lastLoadMoreTime: Date?
    
    let pageSize:Int = 10
    
    var backgroundImageConfigs: [String: BackgroundImageConfig] = [
        "new": BackgroundImageConfig(imageName: "bg_new", horizontalOffset: -100, textColor: .black, tintColor: .systemBlue),
        "beta": BackgroundImageConfig(imageName: "bg_beta", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
        // Add more configurations as needed
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only fetch if the entries array is empty
        if leaderboardEntries.isEmpty {
            fetchLeaderboards()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset all expanded states to false
        for i in 0..<expandedCells.count {
            expandedCells[i] = false
        }
        
        // Refresh the table view to collapse all cells
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Initialize Firestore
        db = Firestore.firestore()
        
        // Register the custom cell
        let nib = UINib(nibName: "LeaderboardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "LeaderboardCell")
        
        // Create the activity indicator
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)

        // Set it as the table footer
        tableView.tableFooterView = spinner
    }
    
    func fetchLeaderboards() {
        query.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No documents returned, assuming end of data")
                self.isMoreDataAvailable = false
                return
            }
            
            // Check if there are fewer documents than the limit, indicating end of data
            if documents.count < self.pageSize {
                self.isMoreDataAvailable = false
            } else {
                self.lastDocumentSnapshot = documents.last
            }
            //self.leaderboardEntries.removeAll()
            for document in documents {
                let leaderboardRank = leaderboardEntries.count + 1
                let entry = self.convertToLeaderboardEntry(document: document, leaderboardRank: leaderboardRank)
                self.leaderboardEntries.append(entry)
            }
            
            // Set the lastDocumentSnapshot for pagination
            self.lastDocumentSnapshot = documents.last
            
            expandedCells = Array(repeating: false, count: leaderboardEntries.count)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.isFetchingMore = false // Reset the fetching flag
                // Once data fetching is complete
                self.tableView.tableFooterView?.isHidden = true  // Hide the spinner

            }
        }
        
    }
    
    func convertToLeaderboardEntry(document: DocumentSnapshot, leaderboardRank: Int) -> LeaderboardEntry {
        let data = document.data()
        let config = backgroundImageConfigs[data?["chosenBadge"] as? String ?? "new"]!
        let entry = LeaderboardEntry(
            userID: data?["userID"] as? String ?? "can't fetch userID",
            rank: leaderboardRank,
            name: data?["name"] as? String ?? "can't fetch name",
            points: data?["points"] as? Int ?? 0,
            division: "placeholderDivision",
            bgConfig: config)
        
        return entry
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if yOffset > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            // User is at the bottom of the table, load more data
            loadMoreData()
        }
    }
    
    func loadMoreData() {
        // Avoid multiple loads
        guard !isFetchingMore else { return }
        if !isMoreDataAvailable {
            // Create and set the "No more data" label as the footer
            tableView.tableFooterView = createNoMoreDataLabel()
            tableView.tableFooterView?.isHidden = false  // Show the spinner
            return
        }

        // Check if at least one second has passed since the last fetch
        if let lastLoadTime = lastLoadMoreTime, Date().timeIntervalSince(lastLoadTime) < 1.0 {
            return
        }
        
        // Update last load time
        lastLoadMoreTime = Date()
        print("attempting to load more data")
        isFetchingMore = true
        
        // Since fetching more, show the loading spinner
        tableView.tableFooterView?.isHidden = false  // Show the spinner
        
        // Check if lastDocumentSnapshot exists
        guard let lastSnapshot = lastDocumentSnapshot else {
            // Handle the scenario - possibly indicating you're at the beginning or end
            print("could not get lastDocumentSnapshot. possibly at beginning or end")
            // Once data fetching is complete or fails
            isFetchingMore = false
            tableView.tableFooterView?.isHidden = true  // Hide the spinner
            return
        }
        
        // Start the next query after the last document
        query = query.start(afterDocument: lastSnapshot).limit(to: self.pageSize)
        fetchLeaderboards() // Using the same fetch method as initial load
    }
    
    func createNoMoreDataLabel() -> UILabel {
        let noMoreDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
        noMoreDataLabel.text = "No more results"
        noMoreDataLabel.font = UIFont.systemFont(ofSize: 16)
        noMoreDataLabel.textColor = UIColor.darkGray  // Or any color that fits your design
        noMoreDataLabel.textAlignment = .center

        return noMoreDataLabel
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardTableViewCell
        
        let entry = leaderboardEntries[indexPath.row]
        cell.configure(with: entry, isExpanded: expandedCells[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Assuming you have an array to track expanded state for each cell
        let isExpanded = expandedCells[indexPath.row]
        expandedCells[indexPath.row] = !isExpanded // Toggle the state
        
        if let cell = tableView.cellForRow(at: indexPath) as? LeaderboardTableViewCell {
            cell.rotateArrow(isExpanded: !isExpanded)
        }
        
        // Option 2: Reload specific row with animation for a smoother experience
        tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedCells[indexPath.row] {
            return expandedHeight // Your expanded height
        } else {
            return normalHeight // Your normal height
        }
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
