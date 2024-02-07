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
    
    static let image:UIImage = UIImage(named: "GLBG")!
    
    static let color:UIColor = UIColor.systemGray6
    static let oneAboveColor:UIColor = UIColor.systemGray5
    static let twoAboveColor:UIColor = UIColor.systemGray4
    static let threeAboveColor:UIColor = UIColor.systemGray3
    
    // Utility function to generate a random color
    static func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0.2...0.3)
        let green = CGFloat.random(in: 0.2...0.3)
        let blue = CGFloat.random(in: 0.3...0.4)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private func commonInit() {
        backgroundColor = CustomBackgroundView.color
        
    }
}

