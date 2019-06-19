//
//  Flag.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/17/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation
import UIKit

class Flag: NSObject, Codable {
    
    var text = ""
    var isChecked = false
    var test = "testing"
    
    override init(){
        super.init()
    }
    func toggleChecked(){
        isChecked = !isChecked
    }
}

