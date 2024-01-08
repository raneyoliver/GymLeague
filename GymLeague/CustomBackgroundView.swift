//
//  CustomBackgroundView.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/6/24.
//

import UIKit

class CustomBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    static let color:UIColor = UIColor.systemGray6
    static let oneAboveColor:UIColor = UIColor.systemGray5
    
    private func commonInit() {
        backgroundColor = CustomBackgroundView.color
    }
}

