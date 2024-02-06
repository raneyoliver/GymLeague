//
//  TutorialViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/4/24.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLayoutConstraint.activate([
            // Set contentView's width equal to scrollView's frameLayoutGuide's width
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Optional: If contentView's height is set to scrollView's height, ensure it's low priority
            // and that there are subviews within contentView that can expand its height beyond scrollView's frame height
        ])

        // Activate scrollView constraints relative to its parent view

    }

}
