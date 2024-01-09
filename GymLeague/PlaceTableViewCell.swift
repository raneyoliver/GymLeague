//
//  PlaceTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/8/24.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeLabel.numberOfLines = 0
        backgroundColor = CustomBackgroundView.color
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = CustomBackgroundView.oneAboveColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with place: Place) {
        // Set up the cell's UI elements with data from the place
        nameLabel.text = place.name
        typeLabel.text = place.types.joined(separator: "\n")
    }

    
}
