//
//  FullScreenImageViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 1/10/24.
//

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupImageView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreen))
        view.addGestureRecognizer(tapGesture)
    }

    func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        view.addSubview(scrollView)
    }

    func setupImageView() {
        imageView = UIImageView(image: image)
        imageView.frame = scrollView.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @objc func dismissFullScreen() {
        dismiss(animated: true, completion: nil)
    }
}
