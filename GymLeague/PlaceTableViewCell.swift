//
//  PlaceTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/8/24.
//

import UIKit
import CoreLocation

class PlaceTableViewCell: UITableViewCell {
    weak var delegate: PlaceTableViewCellDelegate?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var symbolButton: UIButton!
    @IBOutlet weak var textLabelView: UIView!
    var initialColor: UIColor!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.masksToBounds = false
        
        containerView.backgroundColor = CustomBackgroundView.twoAboveColor //UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        contentView.backgroundColor = CustomBackgroundView.oneAboveColor
        
        self.selectionStyle = .none
        
        // Rounded corners
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        
        backgroundImage.layer.cornerRadius = containerView.layer.cornerRadius
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        backgroundImage.addGestureRecognizer(tapGesture)
        backgroundImage.isUserInteractionEnabled = true
        
        // Initialization code
        nameLabel.numberOfLines = 0
        //nameLabel.backgroundColor = CustomBackgroundView.twoAboveColor
        textLabelView.layer.cornerRadius = 8
        textLabelView.clipsToBounds = true
        typeLabel.numberOfLines = 0
        
//
        //setupLayout()

    }
    
    @objc func imageTapped() {
        delegate?.didTapImageView(in: self)
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any properties that might have been altered during configuration
        // such as backgroundImage's offset, transform, or other properties
        backgroundImage.transform = CGAffineTransform.identity  // Reset transform
        // Reset any other custom properties or UI elements
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        containerView.backgroundColor = selected ? initialColor.withAlphaComponent(0.2) : initialColor  // Change colors as needed
        
        containerView.layer.borderWidth = selected ? 3.0 : 0.0  // Optional: if you want a border
        containerView.layer.borderColor = UIColor.systemBlue.cgColor.copy(alpha: 0.65)  // Optional: border color
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        // Configure the view for the highlighted state
        containerView.backgroundColor = highlighted ? initialColor.withAlphaComponent(0.2) : initialColor  // Change colors as needed
    }
    
    func configure(with place: Place, location: CLLocation) {
        // Set up the cell's UI elements with data from the place
        nameLabel.text = place.name
        typeLabel.text = distanceToString(distanceInMiles: place.distance!)
        //print(typeLabel.text!)
        initialColor = CustomBackgroundView.twoAboveColor //place.backgroundColor.withAlphaComponent(0.3)
        containerView.backgroundColor = initialColor
        textLabelView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        backgroundImage.image = UIImage(systemName: "photo")
        if let image = place.image {
            backgroundImage.image = image
            backgroundImage.isUserInteractionEnabled = true
        } else {
            backgroundImage.isUserInteractionEnabled = false
        }
        
        let image:UIImage?
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .small)
        if place.isGym {
            image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: symbolConfiguration)
            symbolButton.tintColor = UIColor.systemBlue
        } else {
            image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: symbolConfiguration)
            symbolButton.tintColor = UIColor.systemYellow
        }
        
        symbolButton.setImage(image, for: .normal)
    }

//    private func setupLayout() {
//        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            backgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
//            backgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            backgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            backgroundImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//        ])
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust the frame of backgroundImage to match the containerView
        backgroundImage.frame = containerView.bounds
    }
    
    func distanceToString(distanceInMiles: Double) -> String {
        if distanceInMiles < 0.2 {
            let distanceInFeet = distanceInMiles * 5280  // miles to feet
            return "\(Int(distanceInFeet)) ft"
        } else {
            return String(format: "%.2f mi", distanceInMiles)
        }
    }
    
}

protocol PlaceTableViewCellDelegate: AnyObject {
    func didTapImageView(in cell: PlaceTableViewCell)
}
