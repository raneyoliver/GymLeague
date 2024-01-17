//
//  MainTabBarViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/13/24.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//
//        swipeLeft.direction = .left
//        swipeRight.direction = .right
//
//        self.view.addGestureRecognizer(swipeLeft)
//        self.view.addGestureRecognizer(swipeRight)
    }

//    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .left {
//            if selectedIndex < (self.viewControllers?.count ?? 0) - 1 {
//                selectedIndex += 1
//            }
//        } else if sender.direction == .right {
//            if selectedIndex > 0 {
//                selectedIndex -= 1
//            }
//        }
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Cannot transition if there is no view
        }

        if fromView != toView {
            animateTransition(fromView: fromView, toView: toView, toViewController: viewController)
        }

        return true
    }


    private func animateTransition(fromView: UIView, toView: UIView, toViewController: UIViewController) {
        // Add the 'toView' to the tab bar view
        self.view.addSubview(toView)
        toView.frame = fromView.frame
        toView.alpha = 0
        toView.layoutIfNeeded()

        // Animate the transition
        UIView.animate(withDuration: 0.3, animations: {
            toView.alpha = 1
            fromView.alpha = 0
        }, completion: { _ in
            fromView.removeFromSuperview()
            if let fromIndex = self.viewControllers?.firstIndex(of: self.selectedViewController ?? UIViewController()), let toIndex = self.viewControllers?.firstIndex(of: toViewController) {
                // Set a direction for the animation
                let direction: CGFloat = toIndex > fromIndex ? 1 : -1
                toView.transform = CGAffineTransform(translationX: direction * toView.frame.size.width, y: 0)
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    toView.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: nil)
            }
        })
    }

}
