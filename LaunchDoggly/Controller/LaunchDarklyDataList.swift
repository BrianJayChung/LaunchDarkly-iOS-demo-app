//
//  FlagList.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/17/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class LaunchDarklyDataList: NSObject, Codable {
    
    var listOfLaunchDarklyData = [LaunchDarklyData]()
    
    override init(){
        super.init()
    }
    
}
