//
//  FilterPillButton.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/31/24.
//

import Foundation
import UIKit

class FilterPillButton: UIButton {
    // Initialize with a specific filter type or name
    init(filterName: String) {
        super.init(frame: .zero)
        setTitle("\(filterName) x", for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        backgroundColor = .systemGray5
        titleLabel?.font = .systemFont(ofSize: 14)
        layer.cornerRadius = 15
        layer.masksToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        addTarget(self, action: #selector(toggleFilter), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Toggle the filter's enabled state
    @objc func toggleFilter() {
        isSelected = !isSelected
        backgroundColor = isSelected ? .systemBlue : .systemGray5
        setTitleColor(isSelected ? .white : .systemBlue, for: .normal)
        
        // Notify the delegate or use a closure to inform about the state change
    }
}
