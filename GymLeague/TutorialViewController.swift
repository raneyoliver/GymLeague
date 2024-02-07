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
    
    var tutorialElements: TutorialElements
    
    // Custom initializer
    init(tutorialElements: TutorialElements) {
        self.tutorialElements = tutorialElements
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = CustomBackgroundView.color
        
        // Create the height constraint using layout anchors
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 852)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Pin contentView edges to scrollView's contentLayoutGuide
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            // Set contentView's width equal to scrollView's frameLayoutGuide's width
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Optional: If contentView's height is set to scrollView's height, ensure it's low priority
            // and that there are subviews within contentView that can expand its height beyond scrollView's frame height
        ])

        let titleLabel = setupTitle()
        setupWorkouts(under: titleLabel)
    }
    

    
    func setupWorkouts(under previousLabel: UILabel) {
        // Create the 'Workouts' subheadline label
        let workoutsSubheadlineLabel = UILabel()
        workoutsSubheadlineLabel.text = "Workouts"
        workoutsSubheadlineLabel.font = .preferredFont(forTextStyle: .headline)
        workoutsSubheadlineLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create the image view for the workouts section
        let workoutsImageView = UIImageView(image: UIImage(systemName: "plus")?.withTintColor(.systemBlue))
        workoutsImageView.translatesAutoresizingMaskIntoConstraints = false

        // Create the description label for the workouts section
        let workoutsDescriptionLabel = UILabel()
        workoutsDescriptionLabel.attributedText = tutorialElements.tipDescription
        workoutsDescriptionLabel.numberOfLines = 0 // Allows label to wrap text
        workoutsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(workoutsSubheadlineLabel)
        contentView.addSubview(workoutsImageView)
        contentView.addSubview(workoutsDescriptionLabel)

        NSLayoutConstraint.activate([
            // Constraints for 'Workouts' subheadline label
            workoutsSubheadlineLabel.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: 40), // Adjust constant as needed
            workoutsSubheadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            //workoutsSubheadlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Constraints for image view in workouts section
            workoutsImageView.topAnchor.constraint(equalTo: workoutsSubheadlineLabel.topAnchor),
            workoutsImageView.leadingAnchor.constraint(equalTo: workoutsSubheadlineLabel.trailingAnchor, constant: 4),
            workoutsImageView.heightAnchor.constraint(equalTo: workoutsSubheadlineLabel.heightAnchor), // Adjust size as needed
            
            // Constraints for workouts description label
            workoutsDescriptionLabel.topAnchor.constraint(equalTo: workoutsSubheadlineLabel.bottomAnchor, constant: 10),
            workoutsDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            workoutsDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            // Ensure you add a bottom constraint to the last element of your contentView or a subsequent element for scrolling
        ])

    }
    
    func setupLast(titleLabel: UILabel) {
        let last = UILabel()
        contentView.addSubview(last)
        last.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            last.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
            last.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //last.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1000)
        ])
        
        last.text = "last"
    }
    
    func setupTitle() -> UILabel {
        let titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
        ])
        
        titleLabel.text = self.tutorialElements.titleLabelText
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .left
        
        return titleLabel
    }

}
