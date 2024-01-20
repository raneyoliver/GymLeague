//
//  CustomHeaderView.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/6/24.
//

import UIKit

class CustomHeaderView: UIView {
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let backgroundImage = UIImageView()
    let topLine = UIView()
    let bottomLine = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Customize and add titleLabel and detailLabel here
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Layout and style titleLabel and detailLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false


        insertSubview(backgroundImage, at: 0)
        addSubview(titleLabel)
        addSubview(detailLabel)
        
        

        // Layout constraints for titleLabel and detailLabel
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16), // Adjust padding as needed

            detailLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16), // Adjust padding as needed
            
            // Constraints for backgroundImage
            backgroundImage.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            //backgroundImage.widthAnchor.constraint(equalToConstant: 309),
            //backgroundImage.heightAnchor.constraint(equalToConstant: 25)
        ])

        // Additional styling
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        titleLabel.shadowColor = UIColor.black
//        titleLabel.shadowOffset = CGSize(width: 1, height: 1)
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textAlignment = .right
//        detailLabel.shadowColor = UIColor.black
//        detailLabel.shadowOffset = CGSize(width: 1, height: 1)
        
        backgroundImage.contentMode = .scaleAspectFill // or .scaleToFill based on your need
        backgroundImage.clipsToBounds = true  // If you want to ensure it doesn't extend outside its bounds
        backgroundImage.alpha = 0.1
        self.backgroundColor = CustomBackgroundView.oneAboveColor //CustomBackgroundView.color
        
    }
}

