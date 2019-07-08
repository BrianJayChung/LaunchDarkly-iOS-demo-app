//
//  AuditLogViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/14/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
//protocol AuditLogViewControllerDelegate: class {
//    func auditLogViewControllerDidLoad(
//        _ controller: AuditLogViewController, didLoad response: [String: String]
//    )
//}

class SettingsPageController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
