//
//  Badge.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/4/24.
//

import Foundation

struct Badge {
    let name: String       // The display name of the badge
    let badgeImageName: String  // The name of the image asset for the badge
    let bgImageName: String
    
    init(name: String, badgeImageName: String, bgImageName: String) {
        self.name = name
        self.badgeImageName = badgeImageName
        self.bgImageName = bgImageName
    }
}
