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
    "bronze": BackgroundImageConfig(imageName: "bg_bronze", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "silver": BackgroundImageConfig(imageName: "bg_silver", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "gold": BackgroundImageConfig(imageName: "bg_gold", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "platinum": BackgroundImageConfig(imageName: "bg_platinum", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "diamond": BackgroundImageConfig(imageName: "bg_diamond", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
    "elite": BackgroundImageConfig(imageName: "bg_elite", horizontalOffset: 0, textColor: .white, tintColor: .systemRed),
]
