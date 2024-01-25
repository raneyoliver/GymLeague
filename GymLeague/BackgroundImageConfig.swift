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
    let accentColor: UIColor

    // Initialize the structure with the settings for a particular image
    init(imageName: String, horizontalOffset: CGFloat, textColor: UIColor, tintColor: UIColor, accentColor: UIColor) {
        self.imageName = imageName
        self.horizontalOffset = horizontalOffset
        self.textColor = textColor
        self.tintColor = tintColor
        self.accentColor = accentColor
    }
}

var backgroundImageConfigs: [String: BackgroundImageConfig] = [
    "default": BackgroundImageConfig(imageName: "bg_default",
                                     horizontalOffset: 0,
                                     textColor: .black,
                                     tintColor: .systemRed,
                                     accentColor: .black),
    
    
    "new": BackgroundImageConfig(imageName: "bg_new",
                                 horizontalOffset: -100,
                                 textColor: .black,
                                 tintColor: .systemGreen,
                                 accentColor: .white),
    
    "beta": BackgroundImageConfig(imageName: "bg_beta",
                                  horizontalOffset: 0,
                                  textColor: .white,
                                  tintColor: .systemPink,
                                  accentColor: .systemCyan),
    
    "hotstreak": BackgroundImageConfig(imageName: "bg_hotstreak",
                                       horizontalOffset: 0,
                                       textColor: .white,
                                       tintColor: .systemRed,
                                       accentColor: .black),
    
    "bronze": BackgroundImageConfig(imageName: "bg_bronze",
                                    horizontalOffset: 0,
                                    textColor: .white,
                                    tintColor: .systemBrown,
                                    accentColor: .black),
    
    "silver": BackgroundImageConfig(imageName: "bg_silver",
                                    horizontalOffset: 0,
                                    textColor: .black,
                                    tintColor: .white,
                                    accentColor: .darkGray),
    
    "gold": BackgroundImageConfig(imageName: "bg_gold",
                                  horizontalOffset: 0,
                                  textColor: .white,
                                  tintColor: .systemOrange,
                                  accentColor: .black),
    
    "platinum": BackgroundImageConfig(imageName: "bg_platinum",
                                      horizontalOffset: 0,
                                      textColor: .white,
                                      tintColor: .systemMint,
                                      accentColor: .black),
    
    "diamond": BackgroundImageConfig(imageName: "bg_diamond",
                                     horizontalOffset: 0,
                                     textColor: .white,
                                     tintColor: .systemIndigo,
                                     accentColor: .systemBlue),
    
    "elite": BackgroundImageConfig(imageName: "bg_elite",
                                   horizontalOffset: 0,
                                   textColor: .white,
                                   tintColor: .clear,
                                   accentColor: .black),
]
