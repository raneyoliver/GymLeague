//
//  LeaderboardTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import GoogleSignIn




class LeaderboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    
    @IBOutlet weak var badgeDescriptionLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var minimizedView: UIView!
    var initialColor:UIColor!
    
    

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any properties that might have been altered during configuration
        // such as backgroundImage's offset, transform, or other properties
        backgroundImage.transform = CGAffineTransform.identity  // Reset transform
        // Reset any other custom properties or UI elements
    }

    
    // Add a function to populate cell data
    func configure(with entry: LeaderboardEntry, isExpanded: Bool, badgeName: String) {
        rankLabel.text = "\(entry.rank)"
        nameLabel.text = entry.name
        badgeDescriptionLabel.text = Config.capitalizeFirstLetter(of: badgeName)
        badgeDescriptionLabel.isHidden = !isExpanded
        backgroundImage.image = UIImage(named: entry.bgConfig.imageName)
        //backgroundImage.tintColor = entry.bgConfig.tintColor
        
        leadingConstraint.constant = entry.bgConfig.horizontalOffset
        //trailingConstraint.constant = -entry.bgConfig.horizontalOffset
        
        //        divisionLabel.text = entry.division
        pointsLabel.text = "\(Int(entry.points))"

        let textLabelColor = entry.bgConfig.textColor
        rankLabel.textColor = textLabelColor
        nameLabel.textColor = textLabelColor
        badgeDescriptionLabel.textColor = textLabelColor
        pointsLabel.textColor = textLabelColor
        arrowButton.tintColor = textLabelColor
        
        let minimizedViewBackgroundColor = entry.bgConfig.tintColor.withAlphaComponent(0.8)
        minimizedView.backgroundColor = minimizedViewBackgroundColor
        let textBackgroundTintColor = UIColor.white.withAlphaComponent(0.3)
//        nameLabel.backgroundColor = textBackgroundTintColor
        rankLabel.backgroundColor = textBackgroundTintColor
        pointsLabel.backgroundColor = textBackgroundTintColor
        let textCornerRadius:CGFloat = 4
        nameLabel.layer.cornerRadius = textCornerRadius
        rankLabel.layer.cornerRadius = textCornerRadius
        pointsLabel.layer.cornerRadius = textCornerRadius
        minimizedView.layer.cornerRadius = 8
        nameLabel.clipsToBounds = true
        rankLabel.clipsToBounds = true
        pointsLabel.clipsToBounds = true
        minimizedView.clipsToBounds = true
        
        //arrowButton.backgroundColor = entry.bgConfig.tintColor
        
//        if entry.bgConfig.textColor != UIColor.black {
//            rankLabel.shadowColor = UIColor.black
//            nameLabel.shadowColor = UIColor.black
//            pointsLabel.shadowColor = UIColor.black
//        } else {
//            rankLabel.shadowColor = UIColor.clear
//            nameLabel.shadowColor = UIColor.clear
//            pointsLabel.shadowColor = UIColor.clear
//        }
        
        if entry.userID == UserData.shared.userID {
            // Additional styling if this is the user's cell
            containerView.layer.borderWidth = 3.0  // Optional: if you want a border
            containerView.layer.borderColor = UIColor.systemBlue.cgColor.copy(alpha: 0.65)  // Optional: border color
        } else {
            // Reset styles for other cells
            containerView.layer.borderWidth = 0  // No border
            containerView.layer.borderColor = UIColor.clear.cgColor  // Clear color or whatever the default is
        }
        
        rotateArrow(isExpanded: isExpanded)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arrowButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)

        initialColor = containerView.backgroundColor
        // Shadow - may need to adjust containerView's layer properties
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.masksToBounds = false
        
        containerView.backgroundColor = UIColor.white
        contentView.backgroundColor = CustomBackgroundView.color
        
        self.selectionStyle = .none
        
        // Rounded corners
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        
        backgroundImage.layer.cornerRadius = containerView.layer.cornerRadius
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Communicate back to the view controller
            NotificationCenter.default.post(name: NSNotification.Name("ToggleExpansionNotification"), object: nil)
        }
    }
    
    func rotateArrow(isExpanded: Bool) {
        // Assuming 0 radians means arrow is pointing left
        // Rotate 90 degrees (π/2 radians) to point down when expanded
        let rotationAngle = isExpanded ? 0 : CGFloat.pi / 2
        UIView.animate(withDuration: 0.3) {
            self.arrowButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
}
