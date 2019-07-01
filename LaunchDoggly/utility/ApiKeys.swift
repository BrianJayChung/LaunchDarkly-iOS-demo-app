//
//  ApiKeys.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/19/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation

var nsDictionary: NSDictionary?

struct ApiKeys {
    var name = "keys"
    var plistKey = "sdk-key"
    
    func ldApiKey() -> String {
        let myDict =  plistContruct(name: name)
        return myDict[plistKey] as! String
    }
    
    func plistContruct(name: String) -> NSDictionary {
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary!
    }
}
