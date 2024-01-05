//
//  LeaderboardSection.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/5/24.
//

import Foundation

struct LeaderboardSection {
    let name: String
    let minPoints: Int
}

let sections = [
    LeaderboardSection(name: "Elite", minPoints: 1000),
    LeaderboardSection(name: "Diamond", minPoints: 500),
    LeaderboardSection(name: "Platinum", minPoints: 250),
    LeaderboardSection(name: "Gold", minPoints: 125),
    LeaderboardSection(name: "Silver", minPoints: 50),
    LeaderboardSection(name: "Bronze", minPoints: 0)  // Assumes everyone has at least 0 points
]
