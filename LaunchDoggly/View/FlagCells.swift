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
    func popUpAlert(alert: UIAlertController)
}

class FlagCell: UICollectionViewCell{
    weak var delegate: FlagCellDelegate?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.layer.cornerRadius = 6.0
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.lightGray.cgColor
        buttnSwitchOutlet.tintColor = .lightGray
        buttnSwitchOutlet.layer.cornerRadius = buttnSwitchOutlet.frame.height / 2
        buttnSwitchOutlet.backgroundColor = .lightGray
    }
    
    @IBOutlet weak var tagTextView: UITextView!
    @IBOutlet weak var flagKey: UILabel!
    @IBOutlet weak var flagName: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var buttnSwitchOutlet: UISwitch!
    
//    @IBAction func buttonSwitch(_ sender: UISwitch) {
//        let alert = UIAlertController(title: "title field", message: "message field", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert: UIAlertAction!) in
//            sender.setOn(false, animated: true)
//            return
//        }))
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
//            sender.setOn(true, animated: true)
//            return
//        }))
//
//        print("button pressed")
//        delegate?.popUpAlert(alert: alert)
////        switchChanged(mySwitch: sender)
//    }
    //let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func invBtn(_ sender: UISwitch) {
        let alert = UIAlertController(title: "title field", message: "message field", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert: UIAlertAction!) in
            self.buttnSwitchOutlet.isOn = false
            return
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
            self.buttnSwitchOutlet.isOn = true
            return
        }))
        
//        buttnSwitchOutlet.isOn = !buttnSwitchOutlet.isOn
        delegate?.popUpAlert(alert: alert)
    }
    
    @IBAction func touchInside(_ sender: UISwitch) {
//        let alert = UIAlertController(title: "title field", message: "message field", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert: UIAlertAction!) in
//            sender.setOn(false, animated: true)
//            return
//        }))
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert: UIAlertAction!) in
//            sender.setOn(true, animated: true)
//            return
//        }))

//        delegate?.popUpAlert(alert: alert)
    }
    
    func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        value ? delegate?.switchOnFlag(self) : delegate?.switchOffFlag(self) // Delegate for the viewcontroll to change the UI color based on flag toggle
    }
}
