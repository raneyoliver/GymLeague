//
//  BackgroundImageConfig.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/3/24.
//

import Foundation
import UIKit

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

var backgroundImageConfigs: [String: BackgroundImageConfig] = [
    "default": BackgroundImageConfig(imageName: "bg_default", horizontalOffset: 0, textColor: .black, tintColor: .systemRed),
    "new": BackgroundImageConfig(imageName: "bg_new", horizontalOffset: -100, textColor: .black, tintColor: .systemBlue),
    "beta": BackgroundImageConfig(imageName: "bg_beta", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "hotstreak": BackgroundImageConfig(imageName: "bg_hotstreak", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    
]
