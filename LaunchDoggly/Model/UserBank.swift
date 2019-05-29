//
//  userBank.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/9/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation

class UserBank {
    var list = [User]()
    
    init(){
        let newQuestionObject = User(text: "John Lee", isMember: true)
        list.append(newQuestionObject)
        let newQuestionObject2 = User(text: "Mary Ann", isMember: false)
        list.append(newQuestionObject2)
        let newQuestionObject3 = User(text: "Josh Bosh", isMember: false)
        list.append(newQuestionObject3)
    }
}
