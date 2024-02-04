//
//  LeaderboardTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/31/23.
//

import UIKit
import GoogleSignIn


struct LeaderboardTableViewCellSettings {
    let textLabelColor: UIColor
    let textBackgroundColor: UIColor
    let minimizedViewBackgroundColor: UIColor
    
    let textCornerRadius: CGFloat
    
    let entry: LeaderboardEntry
    
    init(textLabelColor: UIColor, textBackgroundColor: UIColor, minimizedViewBackgroundColor: UIColor, textCornerRadius: CGFloat, entry: LeaderboardEntry) {
        self.textLabelColor = textLabelColor
        self.textBackgroundColor = textBackgroundColor
        self.minimizedViewBackgroundColor = minimizedViewBackgroundColor
        self.textCornerRadius = textCornerRadius
        self.entry = entry
    }
    
}

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
    
    @IBOutlet weak var backgroundImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var minimizedView: UIView!
    
    @IBOutlet weak var statsView: UIView!
    
    var initialColor:UIColor!
    
    

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    
    // Add a function to populate cell data
    func configure(with entry: LeaderboardEntry, isExpanded: Bool, badgeName: String) {

        let cellSettings = makeCellSettings(with: entry)

        setupMinimizedView(withSettings: cellSettings, isExpanded: isExpanded)
        setupStatsView(withSettings: cellSettings, isExpanded: isExpanded)
        highlightOwnCell(userID: entry.userID)
        
        badgeDescriptionLabel.text = Config.shared.capitalizeFirstLetter(of: badgeName)
        badgeDescriptionLabel.textColor = cellSettings.textLabelColor
        badgeDescriptionLabel.isHidden = !isExpanded
        backgroundImage.image = UIImage(named: entry.bgConfig.imageName)
        leadingConstraint.constant = entry.bgConfig.horizontalOffset
        
    }
    
    func makeCellSettings(with entry: LeaderboardEntry) -> LeaderboardTableViewCellSettings {
        let textLabelColor =  entry.bgConfig.textColor
        let textBackgroundColor = entry.bgConfig.accentColor.withAlphaComponent(0.6)
        let textCornerRadius:CGFloat = 4
        let minimizedViewBackgroundColor = entry.bgConfig.tintColor.withAlphaComponent(0.6)
        
        let cellSettings = LeaderboardTableViewCellSettings(
            textLabelColor: textLabelColor,
            textBackgroundColor: textBackgroundColor,
            minimizedViewBackgroundColor: minimizedViewBackgroundColor,
            textCornerRadius: textCornerRadius,
            entry: entry)
        
        return cellSettings
    }
    
    func highlightOwnCell(userID: String) {
        if userID == UserData.shared.userID {
            containerView.layer.borderWidth = 3.0
            containerView.layer.borderColor = UIColor.systemBlue.cgColor.copy(alpha: 0.65)
        } else {
            // Reset styles for other cells
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func setupStatsView(withSettings cellSettings: LeaderboardTableViewCellSettings, isExpanded: Bool) {
        /// Text
        divisionLabel.text = cellSettings.entry.division
        
        /// Color
        statsView.backgroundColor = cellSettings.minimizedViewBackgroundColor.withAlphaComponent(0.2)
        divisionLabel.backgroundColor = cellSettings.textBackgroundColor
        divisionLabel.textColor = cellSettings.textLabelColor
        
        /// Other
        //statsView.isHidden = !isExpanded
        divisionLabel.layer.cornerRadius = cellSettings.textCornerRadius
        divisionLabel.clipsToBounds = true
    }
    
    func setupMinimizedView(withSettings cellSettings: LeaderboardTableViewCellSettings, isExpanded: Bool) {
        /// Text
        rankLabel.text = "\(cellSettings.entry.rank)"
        nameLabel.text = cellSettings.entry.name
        pointsLabel.text = "\(Int(cellSettings.entry.points))"
        
        /// Color
        rankLabel.textColor = cellSettings.textLabelColor
        nameLabel.textColor = cellSettings.textLabelColor
        pointsLabel.textColor = cellSettings.textLabelColor
        rankLabel.backgroundColor = cellSettings.textBackgroundColor
        pointsLabel.backgroundColor = cellSettings.textBackgroundColor
        minimizedView.backgroundColor = cellSettings.minimizedViewBackgroundColor
        arrowButton.tintColor = cellSettings.entry.bgConfig.accentColor
        
        /// Other
        nameLabel.layer.cornerRadius = cellSettings.textCornerRadius
        rankLabel.layer.cornerRadius = cellSettings.textCornerRadius
        pointsLabel.layer.cornerRadius = cellSettings.textCornerRadius
        nameLabel.clipsToBounds = true
        rankLabel.clipsToBounds = true
        pointsLabel.clipsToBounds = true
        
        /// Arrow
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
        
        
        //backgroundImage.layer.cornerRadius = containerView.layer.cornerRadius
        //backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGesture)
        
        Config.shared.setupBlurEffect(onView: minimizedView, withStyle: .light)

        initStatsView()
    }
    
    func initStatsView() {
        statsView.layer.cornerRadius = 8
        statsView.clipsToBounds = true
        Config.shared.setupBlurEffect(onView: statsView, withStyle: .light)
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
    
    func animateConstraintChange(of constraint: NSLayoutConstraint, withConstant constant: CGFloat) {
        constraint.constant = constant

        // Animate the constraint change
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()  // Use `self.layoutIfNeeded()` for UITableViewCell
        }
    }
    

}
