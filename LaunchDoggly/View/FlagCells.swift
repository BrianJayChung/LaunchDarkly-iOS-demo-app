//
//  FlagCells.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/30/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//


import UIKit

protocol FlagCellDelegate: class {
    
    func switchOnFlag(_ controller: FlagCell)
    func switchOffFlag(_ controller: FlagCell)
    
}

class FlagCell: UICollectionViewCell{
    weak var delegate: FlagCellDelegate?
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
  
    @IBOutlet weak var tagTextView: UITextView!
    @IBOutlet weak var flagKey: UILabel!
    @IBOutlet weak var flagName: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var buttnSwitchOutlet: UISwitch!
    
    @IBAction func buttonSwitch(_ sender: UISwitch) {
        switchChanged(mySwitch: sender)
    }
    //let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        value ? delegate?.switchOnFlag(self): delegate?.switchOffFlag(self) // Delegate for the viewcontroll to change the UI color based on flag toggle
    }
}
