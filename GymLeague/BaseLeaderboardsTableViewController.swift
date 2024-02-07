//
//  BaseLeaderboardsTableViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/6/24.
//

import UIKit

class BaseLeaderboardsTableViewController: BaseViewController {
    var tableViewController: LeaderboardsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the UITableViewController
        tableViewController = LeaderboardsTableViewController(style: .plain)

        // Add as a child view controller
        addChild(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMove(toParent: self)

        // Optionally, set constraints or frame for tableViewController.view
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewController.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableViewController.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        tableViewController.view.backgroundColor = .clear
        self.view.backgroundColor = .clear

    }
}
