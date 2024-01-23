//
//  LeaderboardSection.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/5/24.
//

import Foundation

struct LeaderboardSection {
    let name: String
    let minPoints: Double
}

let sections = [
    nil,    // to account for Leaderboards title
    LeaderboardSection(name: "elite", minPoints: 1000),
    LeaderboardSection(name: "diamond", minPoints: 500),
    LeaderboardSection(name: "platinum", minPoints: 250),
    LeaderboardSection(name: "gold", minPoints: 125),
    LeaderboardSection(name: "silver", minPoints: 50),
    LeaderboardSection(name: "bronze", minPoints: 0)  // Assumes everyone has at least 0 points
]
