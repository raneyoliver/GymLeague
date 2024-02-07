//
//  PageViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/6/24.
//

import UIKit

class PageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var pageViewController: UIPageViewController!
    var subViewControllers: [UIViewController] = [] // Your subheadline view controllers
    var pageControl = UIPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        initSubViewControllers()
        

        // Setup the pageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the initial view controller
        if let firstViewController = subViewControllers.first {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        // Add the pageViewController as a child view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        configurePageControl()
    }
    
    func initSubViewControllers() {
        for elements in tutorials {
            subViewControllers.append(TutorialViewController(tutorialElements: elements))
        }
    }
    
    func configurePageControl() {
        // Add pageControl to the view
        pageControl.frame = CGRect() // Set the frame for your pageControl
        pageControl.numberOfPages = subViewControllers.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        
        // Set constraints or position the pageControl as needed
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // Implement delegate methods to update currentPage of pageControl
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = pageViewController.viewControllers?.first, let index = subViewControllers.firstIndex(of: currentVC) {
                pageControl.currentPage = index
            }
        }
    }

    // Implement UIPageViewController data source methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = subViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil // To make it infinite loop return subViewControllers.last here
        }
        
        guard subViewControllers.count > previousIndex else {
            return nil
        }
        
        return subViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = subViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard subViewControllers.count != nextIndex else {
            return nil // To make it infinite loop return subViewControllers.first here
        }
        
        guard subViewControllers.count > nextIndex else {
            return nil
        }
        
        return subViewControllers[nextIndex]
    }
}
