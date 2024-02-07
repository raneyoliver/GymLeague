//
//  TutorialElements.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/6/24.
//

import Foundation
import UIKit

struct TutorialElements {
    let titleLabelText: String
    let image: UIImage
    let tipDescription: NSMutableAttributedString
}

func descriptionLabelText(image: UIImage, textBefore: String, textAfter: String) -> NSMutableAttributedString {
    // Create the text attachment for the image
    let checkImageAttachment = NSTextAttachment()
    checkImageAttachment.image = image

    // Create attributed strings for the text segments
    let textBeforeImage = NSAttributedString(string: textBefore)
    let textAfterImage = NSAttributedString(string: textAfter)

    // Create an attributed string for the image
    let imageString = NSAttributedString(attachment: checkImageAttachment)

    // Combine text and image into a single attributed string
    let completeText = NSMutableAttributedString()
    completeText.append(textBeforeImage)
    completeText.append(imageString)
    completeText.append(textAfterImage)
    
    return completeText

}

let placeholderImage: UIImage = UIImage(named: "google")!

let tutorials: [TutorialElements] = [
    TutorialElements(
        titleLabelText: "Workouts",
        image: placeholderImage,
        tipDescription: descriptionLabelText(image: UIImage(systemName: "checkmark.seal.fill")!.withTintColor(.systemBlue), textBefore: "Complete a workout (max one per day) by staying at a nearby ", textAfter: "Verified Gym for at least 20 minutes.")),
    
    TutorialElements(titleLabelText: "Unverified Gyms", image: placeholderImage, tipDescription: descriptionLabelText(image: UIImage(systemName: "exclamationmark.triangle.fill")!.withTintColor(.systemYellow), textBefore: "", textAfter: "Unverified Gyms can also be used for workouts if your gym does not appear by requesting it for a whitelist. The gym will then either be whitelisted for future use or be blacklisted at my own discretion (beta).")),
    
    TutorialElements(titleLabelText: "Leaderboard Points", image: placeholderImage, tipDescription: descriptionLabelText(image: placeholderImage, textBefore: "Ten points are awarded per workout. In order to promote competition and consistency, points will decay every single day (00:00 CST) if you have not completed a workout for one week. The points decay as a function: decayed points = initial points - (2 * time since last workout ^ 3) until the points reach 0. For example, after not completing workouts for one week, the first decay would be about 2 points, then gradually increase as you do not complete workouts.", textAfter: ""))
]

//
//TutorialViewController(
//    titleLabelText: "Leaderboards",
//    image: UIImage(named: "google")!,
//    tipDescription: descriptionLabelText(image: UIImage(named: "google")!, textBefore: , textAfter: ""))]
