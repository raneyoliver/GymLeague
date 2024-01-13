//
//  BadgeCollectionViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/3/24.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!  // Connect this IBOutlet to your UIImageView in the storyboard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with badge: Badge, isUnlocked unlocked: Bool, selectedBadge: Badge) {
        if unlocked {
            if let image = UIImage(named: badge.badgeImageName) {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "bg_" + badge.name)
            }
            
        } else {
            imageView.image = UIImage(named: "locked")
        }
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50) // or some other size
        ])

        
        // Make the imageView circular
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true  // Ensure image clips to the bounds of the imageView
        
        if badge.name == selectedBadge.name {
            // Additional styling if this is the user's cell
            imageView.layer.borderWidth = 2.0  // Optional: if you want a border
            imageView.layer.borderColor = UIColor.systemBlue.cgColor.copy(alpha: 0.65)  // Optional: border color
        } else {
            // Reset styles for other cells
            imageView.layer.borderWidth = 0  // No border
            imageView.layer.borderColor = UIColor.clear.cgColor  // Clear color or whatever the default is
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the cornerRadius is updated if the layout changes
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }
    
}
