//
//  FlagCollectionViewCell.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/29/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class FlagCollectionViewCell: UICollectionViewCell {
    
    func FlagCellConfig(cell: UICollectionViewCell){
        
//        let switchOnOff = UISwitch()
//
//        switchOnOff.isOn = true
//
//        switchOnOff.translatesAutoresizingMaskIntoConstraints = false
        
        let flagName = UITextView(frame: CGRect(x: 5, y: 5, width: 200, height: 30))
        
        let flagDescription = UITextView(frame: CGRect(x: 5, y: 50, width: 250, height: 80))
        
        let flagActivity = UITextView(frame: CGRect(x: 5, y: 120, width: 250, height: 50))
        
        flagActivity.text = "--> Last updated - 2 hours ago"
        flagActivity.isEditable = false
        flagActivity.isScrollEnabled = false
        flagActivity.backgroundColor = .white
        
        flagName.text = "Feature Flag"
        flagName.isEditable = false
        flagName.isScrollEnabled = false
        flagName.backgroundColor = .white
        flagName.textColor = UIColor(red: 0.054902, green: 0.0980392, blue: 0.196078, alpha: 1.0)
        
        flagDescription.text = "This feature flag is used to on the front-end checkout page."
        
        
        flagName.font = UIFont.boldSystemFont(ofSize: 18)
        flagDescription.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFont.Weight(0.2))
        
        
        flagDescription.isEditable = false
        flagDescription.isScrollEnabled = false
        flagDescription.backgroundColor = .white
        flagDescription.textColor = .gray
        
        cell.contentView.addSubview(flagActivity)
        cell.contentView.addSubview(flagName)
        cell.contentView.addSubview(flagDescription)
        
//        cell.addSubview(switchOnOff)
//        
//        NSLayoutConstraint(item: switchOnOff, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
//        
//        NSLayoutConstraint(item: switchOnOff, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
//        
    }
}
