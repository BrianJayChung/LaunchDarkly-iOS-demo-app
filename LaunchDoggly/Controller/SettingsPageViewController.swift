//
//  NavBarLunchSettings.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/11/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class Setting: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String){
        self.name = name
        self.imageName = imageName
    }
}

class SettingsPageViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    var mainViewController : ViewController?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight = 40
    
    let settings: [Setting] = {
        return [Setting(name: "Settings", imageName: "settings"), Setting(name: "Information", imageName: "information"), Setting(name: "History", imageName: "history"), Setting(name: "Flags", imageName: "settings-flag"), Setting(name: "Cancel", imageName: "error")]
    }()
    
    
    override init(){
        
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    func showRightCorner() {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.8)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            
            let height: CGFloat = CGFloat(settings.count * cellHeight + 15)
            let y = window.frame.height - height
            
             collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 0.8
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }, completion: nil)
            }
        }
    
    @objc func handleDismiss(setting: Setting){
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }
            
        }) { (Completed: Bool) in
            if type(of: setting) == Setting.self && setting.name != "Cancel" {
                
                self.mainViewController?.showControllerForSetting(setting: setting)
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SettingCell
        let cellSetting = settings[indexPath.item]
        cell.setting = cellSetting
        return cell
        
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: CGFloat(cellHeight))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let setting = self.settings[indexPath.item]
        handleDismiss(setting: setting)
        
    }
}
