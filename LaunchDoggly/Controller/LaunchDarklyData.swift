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
    
    var projectIsChecked = false
    var environmentIsChecked = false
    
    var projectTitle = "[ Project ]"
    var projectKey: String?
    var flagState: Bool?
    var envirKeys = [String]()
    var environmentsList = [LaunchDarklyData]()
    var flagsList = [JSON]()
    
    var envirName: String?
    var envirKey: String?
    
    override init(){
        super.init()
    }
    
    func toggleProjectChecked(){
        projectIsChecked = !projectIsChecked
    }
    
    func toggleEnvironmentChecked(){
        environmentIsChecked = !environmentIsChecked
    }
}


