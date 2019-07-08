//
//  Extensions.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/14/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

var vSpinner: UIView?

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
    }
}

extension UIViewController {
    func showSpinner(onView: UIView, offSet: CGFloat) {
//        let spinnerView = UIView.init(frame: CGRect(x: 0, y: 150, width: onView.frame.width, height: onView.frame.height))
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.frame.size.height = onView.frame.height + offSet
        
        spinnerView.backgroundColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 00)
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
