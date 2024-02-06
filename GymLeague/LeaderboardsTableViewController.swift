//
//  LeaderboardsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import FirebaseFirestore
import GoogleSignIn

class LeaderboardsTableViewController: UITableViewController {
    
    var db: Firestore!
    var leaderboardEntries = [LeaderboardEntry]()

    // Create a structure to hold leaderboard entries in each section
    var sectionedEntries = [[LeaderboardEntry]]()

    var expandedCells = [[Bool]]()
    
    let expandedHeight:CGFloat = 168
    let normalHeight:CGFloat = 50
    
    // Define the initial query
    lazy var query: Query = db.collection("leaderboards").order(by: "points", descending: true).limit(to: 20)
    
    var lastDocumentSnapshot: DocumentSnapshot?
    
    var isFetchingMore = true
    
    var isMoreDataAvailable = true
    
    var lastLoadMoreTime: Date?
    
    let pageSize:Int = 10
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset all expanded states to false
        // Update expandedCells for each section
        for (sectionIndex, section) in expandedCells.enumerated() {
            expandedCells[sectionIndex] = Array(repeating: true, count: section.count)
        }
        sectionedEntries = Array(repeating: [], count: sections.count)

        // Refresh the table view to collapse all cells
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleAllCells), name: NSNotification.Name("ToggleExpansionNotification"), object: nil)

        sectionedEntries = Array(repeating: [], count: sections.count)
    
        tableView.backgroundColor = CustomBackgroundView.color
    }
    
    func initializeExpandedCells() {
        expandedCells = sectionedEntries.map { section in
            return Array(repeating: true, count: section.count)
        }
    }

    
    @objc func refreshData() {
        // Code to refresh leaderboard data
        self.leaderboardEntries.removeAll()
        fetchLeaderboards()  // Assuming this method fetches and reloads your data
    }
    
    @objc func toggleAllCells() {
        // Determine the new expanded state
        let shouldExpand = expandedCells.contains { $0.contains(true) } == false
        
        // Update expandedCells for each section
        for (sectionIndex, section) in expandedCells.enumerated() {
            expandedCells[sectionIndex] = Array(repeating: shouldExpand, count: section.count)
        }
        
        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Reload the table view
        tableView.reloadData()
    }

    
    func fetchLeaderboards() {
        print("Starting to fetch leaderboards") // Log start
        isFetchingMore = true
                
        query.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents returned, assuming end of data")
                self.isMoreDataAvailable = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            
            // Process for end of data
            if documents.count < self.pageSize {
                self.isMoreDataAvailable = false
            }
            
            // Update leaderboardEntries and sectionedEntries
            self.processNewDocuments(documents)
            
            
            print("Finished processing documents. Now reloading data.") // Log finish
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.isFetchingMore = false // Reset the fetching flag
                self.tableView.reloadData()
                
                // Once data fetching is complete
                self.tableView.tableFooterView?.isHidden = true  // Hide the spinner
            }
        }
    }

    func processNewDocuments(_ documents: [QueryDocumentSnapshot]) {
        // Ensure this is called within the fetchLeaderboards completion
        let newEntriesStartIndex = leaderboardEntries.count
        var leaderboardRank = newEntriesStartIndex
        for document in documents {
            leaderboardRank += 1
            let entry = self.convertToLeaderboardEntry(document: document, leaderboardRank: leaderboardRank)
            self.leaderboardEntries.append(entry)
            if let sectionIndex = sections.firstIndex(where: {
                var enoughPointsForRank:Bool = false
                if let minPoints = $0?.minPoints {
                    enoughPointsForRank = entry.points >= minPoints
                }
                
                return enoughPointsForRank
            }) {
                // Initialize the section array if needed
                if sectionIndex >= sectionedEntries.count {
                    sectionedEntries.append([])
                }
                sectionedEntries[sectionIndex].append(entry)
            }
        }
        
        // Set the lastDocumentSnapshot for pagination
        self.lastDocumentSnapshot = documents.last
        initializeExpandedCells()
    }

    
    func convertToLeaderboardEntry(document: DocumentSnapshot, leaderboardRank: Int) -> LeaderboardEntry {
        let data = document.data()
        let config = backgroundImageConfigs[data?["chosenBadge"] as? String ?? "default"]!
        let entry = LeaderboardEntry(
            userID: data?["userID"] as? String ?? "can't fetch userID",
            rank: leaderboardRank,
            name: data?["username"] as? String ?? "can't fetch username",
            points: data?["points"] as? Double ?? 0,
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
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFetchingMore ? 0 : sectionedEntries[section].count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = UIView()
            let titleLabel = UILabel()
            titleLabel.text = "Leaderboards"
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            titleLabel.textAlignment = .left
            
            header.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 8),
                titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
            
            let infoButton = UIButton()
            infoButton.setTitle("", for: .normal)
            infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
            header.addSubview(infoButton)
            infoButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                infoButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -10),
                infoButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                infoButton.heightAnchor.constraint(equalToConstant: 40),
                infoButton.widthAnchor.constraint(equalToConstant: 40)
            ])
            
            infoButton.addTarget(self, action: #selector(showTutorial), for: .touchUpInside)
            
            return header
        } else if sectionedEntries[section].isEmpty {
            return nil
        } else {
            let header = CustomHeaderView()
            //let bgConfig = backgroundImageConfigs[sections[section]!.name]
            header.titleLabel.text = Config.shared.capitalizeFirstLetter(of: sections[section]!.name)
            header.detailLabel.text = "\(Int(sections[section]!.minPoints))+"  // Set this to your detail text
            
            header.titleLabel.textColor = UIColor.label
            header.detailLabel.textColor = UIColor.label
            //        header.titleLabel.textColor = bgConfig!.textColor
            //        header.detailLabel.textColor = bgConfig!.textColor
            
            //let imageName = bgConfig!.imageName
            //header.backgroundImage.image = UIImage(named: imageName)
            return header
        }
    }
    
    @objc func showTutorial() {
        let tutorialVC = TutorialViewController()
        self.present(tutorialVC, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 25
        }
        else if sectionedEntries.allSatisfy({ $0.isEmpty }) {
            return 25
        } else {
            return sectionedEntries[section].isEmpty ? 0 : 25
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude  // Adjust this value for the desired space below each section
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardTableViewCell
        
        let isExpanded = expandedCells[indexPath.section][indexPath.row]
        let entry = sectionedEntries[indexPath.section][indexPath.row]
        cell.configure(with: entry, isExpanded: isExpanded, badgeName: backgroundImageConfigs.first(where: {$0.value.imageName == entry.bgConfig.imageName})!.key)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleCellExpanded(at: indexPath)
        
        if let cell = tableView.cellForRow(at: indexPath) as? LeaderboardTableViewCell {
            cell.rotateArrow(isExpanded: expandedCells[indexPath.section][indexPath.row])
        }
        
        // Option 2: Reload specific row with animation for a smoother experience
        tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Example: Toggling the expanded state of a cell
    func toggleCellExpanded(at indexPath: IndexPath) {
        // Ensure indices are within range
        if indexPath.section < expandedCells.count && indexPath.row < expandedCells[indexPath.section].count {
            expandedCells[indexPath.section][indexPath.row].toggle()
            //tableView.reloadRows(at: [indexPath], with: .none)
            tableView.reloadData()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedCells[indexPath.section][indexPath.row] {
            return expandedHeight // Your expanded height
        } else {
            return normalHeight // Your normal height
        }
    }
   
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   }

extension Notification.Name {
    static let badgeUpdated = Notification.Name("BadgeUpdatedNotification")
}
