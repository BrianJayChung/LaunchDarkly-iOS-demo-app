//
//  ViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/9/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit
import LaunchDarkly

protocol ProjectSelectedDelegate {
    func projectSelected(projectName: String?)
}

protocol EnvirSelectedDelegate{
    func envirSelected(envirName: String?)
}

class ViewController: UIViewController, ProjectSelectedDelegate, EnvirSelectedDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        super.viewDidLoad()
        navBarItemFont()
        LDClient.sharedInstance().delegate = self
        collectionView.register(FlagCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    
    let cellHeight = 150
    let colorChange = UIColorFromRGB()
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Instantiate the flagcollection view cell 
    let flagCells = FlagCollectionViewCell()
    
    @IBOutlet weak var projectBarBtnItem: UIBarButtonItem!
    @IBOutlet weak var envirBarBtnItem: UIBarButtonItem!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlagCell
        
        //TODO: Fix duplication of switches with using the below method
        /*
                let switchOnOff = UISwitch()
                switchOnOff.tag = 100
                switchOnOff.translatesAutoresizingMaskIntoConstraints = false
                switchOnOff.setOn(true, animated: true)
                cell.contentView.addSubview(switchOnOff)
         
                NSLayoutConstraint(item: switchOnOff, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
         
                NSLayoutConstraint(item: switchOnOff, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        */
        
//        flagCells.FlagCellConfig(cell: cell)


        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: CGFloat(cellHeight))
        
    }
    // MARK: LaunchDarkly fron-end key
    // This is safe to expose as it can only fetch the flag evaluation outcome

    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    let customizeNavBarTitle = NavBarTitleFontStyle()
    //Set feature flag key here
    //fileprivate let menuFlagKey = "show-widgets"
    fileprivate let backgroundColorKey = "background-color"
    

    
    var projectButtonText : String?
    var envirButtonText : String?
    
    var topLeftMenuPageIsVisible = false
    
    
    // Delegate functions to handle project/environment picked
    func projectSelected(projectName: String?) {
        projectBarBtnItem.title = projectName
    }
    
    func envirSelected(envirName envir: String?) {
        
        envirBarBtnItem.title = envir
        
    }
    
    func navBarItemFont(){
        
        customizeNavBarTitle.fontSizeSetting(fontSize: 13, barBtnItem: envirBarBtnItem, state: .normal)
        customizeNavBarTitle.fontSizeSetting(fontSize: 14, barBtnItem: envirBarBtnItem, state: .selected)
        customizeNavBarTitle.fontSizeSetting(fontSize: 15, barBtnItem: projectBarBtnItem, state: .normal)
        customizeNavBarTitle.fontSizeSetting(fontSize: 16, barBtnItem: projectBarBtnItem, state: .normal)
        
    }
    
    @IBAction func projectBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToProjects", sender: self)
    }
    
    @IBAction func environmentBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToEnvironments", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "pushToProjects" {
            let nav = segue.destination as! ProjectTableView
            nav.checkedProject = projectBarBtnItem.title!
            nav.delegate = self
        }
        if segue.identifier == "pushToEnvironments" {
            let envVC = segue.destination as! EnvironmentsTableView
            envVC.selectedEnvir = envirBarBtnItem.title!
            envVC.delegate = self
        }
    }
    
    lazy var navBarLaunchSettings: SettingsPageViewController = {
        let navBarLaunchSettings = SettingsPageViewController()
        navBarLaunchSettings.mainViewController = self
        return navBarLaunchSettings
    }()
    
    
    @IBAction func inBoxClick(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        navBarLaunchSettings.showRightCorner()
    }

    func showControllerForSetting(setting: Setting){
        let dummyController = UIViewController()
        dummyController.navigationItem.title = setting.name
        dummyController.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.pushViewController(dummyController, animated: true)

    }
    
    // Function to set the background feature flag
    fileprivate func checkBackgroundFeatureValue(){
        let featureFlagValue = LDClient.sharedInstance().boolVariation(backgroundColorKey, fallback: false)
        if featureFlagValue {
            mainView.backgroundColor = UIColor(red: 0.054902, green: 0.0980392, blue: 0.196078, alpha: 1.0)
        }
        else {
            mainView.backgroundColor = .brown
        }
    }
}

// LaunchDarkly SDK delegate
extension ViewController: ClientDelegate {
    func featureFlagDidUpdate(_ key: String) {
        if key == backgroundColorKey {
            checkBackgroundFeatureValue()
        }
    }
}
