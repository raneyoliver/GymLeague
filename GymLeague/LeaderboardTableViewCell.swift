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
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var initialColor:UIColor!
    
    


    
    // Add a function to populate cell data
    func configure(with entry: LeaderboardEntry, isExpanded: Bool) {
        rankLabel.text = "\(entry.rank)"
        nameLabel.text = entry.name
        backgroundImage.image = UIImage(named: entry.bgConfig.imageName)
        backgroundImage.tintColor = entry.bgConfig.tintColor
        leadingConstraint.constant += entry.bgConfig.horizontalOffset
        trailingConstraint.constant -= entry.bgConfig.horizontalOffset
        
        //        divisionLabel.text = entry.division
        pointsLabel.text = "\(entry.points)"
        
        rankLabel.textColor = entry.bgConfig.textColor
        nameLabel.textColor = entry.bgConfig.textColor
        pointsLabel.textColor = entry.bgConfig.textColor
        arrowButton.tintColor = entry.bgConfig.textColor
        
        //        if entry.userID == UserData.shared.userID {
        //            self.backgroundColor = UIColor.blue
        //        }
        
        rotateArrow(isExpanded: isExpanded)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let offsetAmount: CGFloat = 100  // Change this value to whatever you need
//        leadingConstraint.constant -= offsetAmount  // Move image to the left
//        widthConstraint.constant += offsetAmount   // Incr
        //backgroundImage.transform = CGAffineTransform(translationX: offsetAmount, y: 0)  // Adjust x as needed
        
        // Translucency
        //containerView.backgroundColor = containerView.backgroundColor?.withAlphaComponent(0.5)
        
        initialColor = containerView.backgroundColor
        
        arrowButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)

        
        // Shadow - may need to adjust containerView's layer properties
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.masksToBounds = false
        
        self.selectionStyle = .none
        
        // Rounded corners
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        
        backgroundImage.layer.cornerRadius = containerView.layer.cornerRadius
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        
        
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.3) // Adjust as needed
        } else {
            containerView.backgroundColor = initialColor // Or your default color
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.3) // Adjust as needed
        } else {
            containerView.backgroundColor = initialColor // Or your default color
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
