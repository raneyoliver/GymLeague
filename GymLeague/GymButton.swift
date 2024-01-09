//
//  GymButton.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/8/24.
//

import UIKit

class GymButton: UIButton {
    
    // Initialize with custom visuals
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Circular shape
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true

        // Colors and visuals
        updateForState(isEnabled: self.isEnabled)
        
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
    }
    
    // Call this whenever isEnabled changes
    func updateForState(isEnabled: Bool) {
        if isEnabled {
            self.backgroundColor = UIColor.systemBlue  // Or any vibrant color
            self.layer.shadowRadius = 4  // Visible shadow when enabled
        } else {
            self.backgroundColor = UIColor.lightGray  // Muted color when disabled
            self.layer.shadowRadius = 0  // No shadow when disabled
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateForState(isEnabled: isEnabled)
        }
    }
}


