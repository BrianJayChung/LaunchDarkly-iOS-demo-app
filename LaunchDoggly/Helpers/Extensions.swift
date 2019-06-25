//
//  Extensions.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/14/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

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
    func showSpinner(onView: UIView) {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        
        spinnerView.backgroundColor = UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        
        onView.addSubview(spinnerView)
        
        
    }
}
