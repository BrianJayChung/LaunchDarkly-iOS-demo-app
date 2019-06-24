//
//  AccountPageViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/13/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let ColorChange = UIColorFromRGB()
    
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        loginButton.layer.cornerRadius = 0.50 * loginButton.bounds.size.height
        loginButton.backgroundColor = ColorChange.UIColorFromRGB(rgbValue: 8691109)
        passwordField.isSecureTextEntry = true
        
    }
    
    //TO DO: Add user authentication
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
