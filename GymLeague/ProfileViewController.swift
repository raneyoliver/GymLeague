//
//  ProfileViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import Foundation
import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var saveButton: UIButton!
    var profileLeaderboardCell:LeaderboardTableViewCell!
    
    var availableBadges:[Badge] = Array()
    var selectedBadge: Badge?

    var isExpanded = true
    let expandedHeight:CGFloat = 168
    let normalHeight:CGFloat = 50
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isExpanded = true
        
        selectedBadge = MakeBadge(fromName: UserData.shared.chosenBadge!)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the custom cell - assuming you're using a nib
        let nib = UINib(nibName: "BadgeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "BadgeCell")

        fetchBadges()

        saveButton.isEnabled = false
        selectedBadge = MakeBadge(fromName: UserData.shared.chosenBadge!)
        
        // Rounded corners
        collectionView.layer.cornerRadius = 8
        collectionView.clipsToBounds = true
        
        collectionView.backgroundColor = CustomBackgroundView.oneAboveColor
        tableView.backgroundColor = CustomBackgroundView.color
        tableView.isScrollEnabled = false
        
    }
    
    
    
    func setupProfileLeaderboardCell(profileLeaderboardCell: LeaderboardTableViewCell, withBadge chosenBadgeName: String) {
        LeaderboardService.shared.getUserRank { rank, error in
            DispatchQueue.main.async {
                if let rank = rank {
                    //print("The user's rank is \(rank)")
                    // Update UI or perform further actions with the rank
                    
                    let config = backgroundImageConfigs[chosenBadgeName]
                    let entry = LeaderboardEntry(
                        userID: "", //not needed
                        rank: rank,
                        name: UserData.shared.givenName!,
                        points: UserData.shared.points!,
                        division: "placeholderDivision",
                        bgConfig: config!)
                    
                    profileLeaderboardCell.configure(with: entry, isExpanded: self.isExpanded)
                    
                } else if let error = error {
                    print("Error getting user rank: \(error.localizedDescription)")
                    // Handle error
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Register the NIB for LeaderboardTableViewCell
        let nib = UINib(nibName: "LeaderboardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ProfileLeaderboardCell")
        
        profileLeaderboardCell = tableView.dequeueReusableCell(withIdentifier: "ProfileLeaderboardCell", for: indexPath) as? LeaderboardTableViewCell

        // Configure the cell
        setupProfileLeaderboardCell(profileLeaderboardCell: profileLeaderboardCell, withBadge: selectedBadge!.name)

        return profileLeaderboardCell
    }

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isExpanded = !isExpanded // Toggle the state
        
        if let cell = tableView.cellForRow(at: indexPath) as? LeaderboardTableViewCell {
            cell.rotateArrow(isExpanded: isExpanded)
        }
        
        // Option 2: Reload specific row with animation for a smoother experience
        tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    @objc func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded {
            return expandedHeight // Your expanded height
        } else {
            return normalHeight // Your normal height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allBadgeNames.count
    }
    
    func fetchBadges() {
        guard let userID = UserData.shared.userID else {
            print("User ID not available")
            return
        }

        LeaderboardService.shared.fetchLeaderboardEntry(forUserID: userID) { document, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error fetching documents: \(error!.localizedDescription)")
                    return
                }

                if let data = document?.data(), let badges = data["badges"] as? [String] {
                    // Assume that you have a way to convert badge strings to Badge objects
                    self.availableBadges = badges.map { Badge(name: $0, badgeImageName: "badge_\($0)", bgImageName: "bg_\($0)") }
                    self.collectionView.reloadData()
                } else {
                    print("Cannot fetch user badges")
                }
            }
        }
        // Once data is fetched and availableBadges is updated:
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as! BadgeCollectionViewCell
        let badgeName = allBadgeNames[indexPath.row]
        let badge = Badge(name: badgeName, badgeImageName: "badge_" + badgeName, bgImageName: "bg_" + badgeName)
        let unlocked = availableBadges.contains { $0.name == badgeName }
        cell.configure(with: badge, isUnlocked: unlocked)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badgeName = allBadgeNames[indexPath.row]
        let unlocked = availableBadges.contains { $0.name == badgeName }
        if unlocked {
            selectedBadge = Badge(name: badgeName, badgeImageName: "badge_" + badgeName, bgImageName: "bg_" + badgeName)
            setupProfileLeaderboardCell(profileLeaderboardCell: profileLeaderboardCell, withBadge: selectedBadge!.name)
            updateSaveButtonState()
        }
        
    }

//    func updatePreviewCell(with badge: Badge, at indexPath: IndexPath) {
//        setupProfileLeaderboardCell(profileLeaderboardCell: cell, withBadge: badge.name)
//    }

    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        guard let userID = UserData.shared.userID, let chosenBadge = selectedBadge?.name else {
            print("Error: User ID or selected badge not available")
            return
        }
    
        LeaderboardService.shared.updateChosenBadge(forUserID: userID, chosenBadge: chosenBadge) { success in
            if success {
                print("Chosen badge updated successfully")
                self.updateSaveButtonState()
                NotificationCenter.default.post(name: .badgeUpdated, object: nil)
            } else {
                print("Failed to update chosen badge")
            }
        }
    }

    func updateSaveButtonState() {
        if UserData.shared.chosenBadge == selectedBadge?.name {
            // If there is no change in badge, disable and grey out the save button
            saveButton.isEnabled = false
            //saveButton.backgroundColor = .gray // Or any color that indicates it's disabled
        } else {
            // If there is a change, enable and highlight the save button
            saveButton.isEnabled = true
            //saveButton.backgroundColor = .systemBlue // Or any color that indicates it's active
        }
    }

    
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                // Set image data here
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
