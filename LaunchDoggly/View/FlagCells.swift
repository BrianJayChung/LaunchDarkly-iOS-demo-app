//
//  FlagCells.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/30/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//


import UIKit

protocol FlagCellDelegate: class{
    func switchOnFlag(_ controller: FlagCell)
    func switchOffFlag(_ controller: FlagCell)
}

class FlagCell: UICollectionViewCell{
    
    weak var delegate: FlagCellDelegate?
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let buttonSwitch: UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setOn(true, animated: true)
        return button
    }()
    
    func setupViews(){
        
        self.backgroundColor = .white
        
        addSubview(buttonSwitch)
        NSLayoutConstraint(item: buttonSwitch, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        
        NSLayoutConstraint(item: buttonSwitch, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        let flagName = UITextView(frame: CGRect(x: 5, y: 5, width: 200, height: 30))
        
        let flagDescription = UITextView(frame: CGRect(x: 5, y: 50, width: 250, height: 50))
        
        let flagActivity = UITextView(frame: CGRect(x: 5, y: 110, width: 250, height: 40))
        
        flagActivity.text = "--> Last updated - 2 hours ago"
        flagActivity.isEditable = false
        flagActivity.isScrollEnabled = false
        flagActivity.backgroundColor = .clear
        
        flagName.text = "Feature Flag"
        flagName.isEditable = false
        flagName.isScrollEnabled = false
        flagName.backgroundColor = .white
        flagName.textColor = UIColor(red: 0.054902, green: 0.0980392, blue: 0.196078, alpha: 1.0)
        
        flagDescription.text = "This feature flag is used to turn on the front-end checkout page."
        
        
        flagName.font = UIFont.boldSystemFont(ofSize: 18)
        flagDescription.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFont.Weight(0.2))
        
        
        flagDescription.isEditable = false
        flagDescription.isScrollEnabled = false
        flagDescription.backgroundColor = .white
        flagDescription.textColor = .gray
        
        self.contentView.addSubview(flagActivity)
        self.contentView.addSubview(flagName)
        self.contentView.addSubview(flagDescription)
    }
    
    func listenBtnChange(){
        buttonSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        
        let value = mySwitch.isOn
        value ? delegate?.switchOnFlag(self): delegate?.switchOffFlag(self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
