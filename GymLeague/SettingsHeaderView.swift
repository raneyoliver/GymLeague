//
//  SettingsHeaderView.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/7/24.
//

import Foundation
import UIKit

class SettingsHeaderView: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let returnButton = UIButton(type: .system)
    
    weak var delegate: SettingsHeaderViewDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupHeader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHeader()
    }

    private func setupHeader() {
        // Configure returnButton
        if let image = UIImage(systemName: "arrow.turn.up.left") {
            returnButton.setImage(image, for: .normal)
        }
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        // Configure titleLabel
        titleLabel.text = "Settings"
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .left
        
        addSubview(titleLabel)
        addSubview(returnButton)
        
        // Set translatesAutoresizingMaskIntoConstraints to false for Auto Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for titleLabel (centered in header)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            //titleLabel.widthAnchor.constraint(equalToConstant: 100),
            //titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Constraints for returnButton (aligned to left and vertically centered)
        NSLayoutConstraint.activate([
            returnButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            returnButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            returnButton.widthAnchor.constraint(equalToConstant: 50),
            returnButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
//    override func layoutSubviews() {
//        titleLabel.frame = CGRect(x: (self.bounds.width - 100) / 2, y: 10, width: 100, height: 50)
//        returnButton.frame = CGRect(x: 10, y: (self.bounds.height - 50) / 2, width: 50, height: 50)
//    }
    
    @objc func returnButtonTapped() {
        delegate?.didTapReturnButton()
    }


}

protocol SettingsHeaderViewDelegate: AnyObject {
    func didTapReturnButton()
}
