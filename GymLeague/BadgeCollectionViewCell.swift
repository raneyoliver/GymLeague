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
    
    func configure(with badge: Badge, isUnlocked unlocked: Bool) {
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
        
        // Additional styling
        //imageView.layer.borderWidth = 1.0  // Optional: if you want a border
        //imageView.layer.borderColor = UIColor.lightGray.cgColor  // Optional: border color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the cornerRadius is updated if the layout changes
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }
    
}
