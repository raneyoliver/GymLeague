//
//  PlaceTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/8/24.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    weak var delegate: PlaceTableViewCellDelegate?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
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
        containerView.backgroundColor = selected ? CustomBackgroundView.threeAboveColor : CustomBackgroundView.twoAboveColor  // Change colors as needed
        
        containerView.layer.borderWidth = selected ? 3.0 : 0.0  // Optional: if you want a border
        containerView.layer.borderColor = UIColor.systemBlue.cgColor.copy(alpha: 0.65)  // Optional: border color
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        // Configure the view for the highlighted state
        containerView.backgroundColor = highlighted ? CustomBackgroundView.threeAboveColor : CustomBackgroundView.twoAboveColor  // Change colors as needed
    }
    
    func configure(with place: Place) {
        // Set up the cell's UI elements with data from the place
        nameLabel.text = place.name
        typeLabel.text = place.types.joined(separator: "\n")
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

    
}

protocol PlaceTableViewCellDelegate: AnyObject {
    func didTapImageView(in cell: PlaceTableViewCell)
}
