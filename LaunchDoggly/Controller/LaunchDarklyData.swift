//
//  LaunchDarklyData.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/20/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class LaunchDarklyData: NSObject, Codable {
    
    var isChecked = false
    
    var projectTitle = "[ Project ]"
    var projectKey: String?
    
//    var jsonResponse: JSON?
    var environmentsList = [String]()
    
    override init(){
        super.init()
    }
    func toggleChecked(){
        isChecked = !isChecked
    }
}


