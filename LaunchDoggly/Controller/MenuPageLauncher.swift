//
//  MenuLaunchSettingsViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/23/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit


class SliderMenuViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override init(){
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LeftMenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    let blackView = UIView()
    
    // MARK: - Create the collection view
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let settings: [Setting] = {
        return [Setting(name: "Settings", imageName: "settings"), Setting(name: "Information", imageName: "information"), Setting(name: "History", imageName: "history"), Setting(name: "Flags", imageName: "settings-flag"), Setting(name: "Cancel", imageName: "error")]
    }()
    
    let cellId = "cellId2"
    let cellHeight = 40
    
    // When left hamburger menu is clicked
    func showLeftMenu() {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.8)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView) // blackView is used to recognize gestures for dissmissal
            window.addSubview(collectionView) // add the collection view created above
            
            collectionView.frame = CGRect(x: 0, y: 0, width: 0, height: window.frame.height)

            blackView.frame = window.frame
            blackView.alpha = 0

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: 130, height: window.frame.height)

            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.collectionView.frame = CGRect(x: -130, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! LeftMenuCell
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
}
