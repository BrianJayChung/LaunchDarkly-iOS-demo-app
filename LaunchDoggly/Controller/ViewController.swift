//
//  ViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/9/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//
import UIKit
import LaunchDarkly

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var projectBtnText: String?
    var envirBtnText: String?
    
    let ColorChange = UIColorFromRGB()
    
    override func viewDidLoad() {
        
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        
        super.viewDidLoad()
        
        checkBackgroundFeatureValue()
        //        navBarItemFont()
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        LDClient.sharedInstance().delegate = self
        collectionView.register(FlagCell.self, forCellWithReuseIdentifier: "Cell")
        
        projectBtnText = "Choose Project"
        envirBtnText = "Choose Environment"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        projectBarButton.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
        projectBarButton.setTitle(projectBtnText! + " \u{2304}", for: .normal)
        
        envirBarBtnItem.setTitle(envirBtnText! + " \u{2304}", for: .normal)
        
        projectBarButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        envirBarBtnItem.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
    }
    // MARK: LaunchDarkly fron-end key
    // This is safe to expose as it can only fetch the flag evaluation outcome
    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    
    //Set feature flag key here
    //fileprivate let menuFlagKey = "show-widgets"
    fileprivate let backgroundColorKey = "background-color"
    
    let cellHeight = 150
    
    let customizeNavBarTitle = NavBarTitleFontStyle()
    
    lazy var navBarLaunchSettings: SettingsPageViewController = {
        let navBarLaunchSettings = SettingsPageViewController()
        navBarLaunchSettings.mainViewController = self
        return navBarLaunchSettings
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var projectBarButton: UIButton!
    @IBOutlet weak var envirBarBtnItem: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBAction func projectBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToProjects", sender: self)
    }
    
    @IBAction func environmentBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToEnvironments", sender: self)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        view.endEditing(true)
        navBarLaunchSettings.showRightCorner()
    }
//    @IBAction func menuClicked(_ sender: UIBarButtonItem) {
//        view.endEditing(true)
//        navBarLaunchSettings.showRightCorner()
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlagCell
        cell.delegate = self
        cell.buttonSwitch.tag = indexPath.row // will use this to target each row
        cell.listenBtnChange()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: CGFloat(cellHeight))
        
    }
    
    //    func navBarItemFont(){
    //
    //        customizeNavBarTitle.fontSizeSetting(fontSize: 13, barBtnItem: envirBarBtnItem, state: .normal)
    //        customizeNavBarTitle.fontSizeSetting(fontSize: 14, barBtnItem: envirBarBtnItem, state: .selected)
    //        customizeNavBarTitle.fontSizeSetting(fontSize: 15, barBtnItem: projectBarBtnItem, state: .normal)
    //        customizeNavBarTitle.fontSizeSetting(fontSize: 16, barBtnItem: projectBarBtnItem, state: .normal)
    //
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "pushToProjects" {
            let projVC = segue.destination as! ProjectTableView
            projVC.checkedProject = projectBtnText
            projVC.delegate = self
        }
        if segue.identifier == "pushToEnvironments" {
            let envVC = segue.destination as! EnvironmentsTableView
            envVC.selectedEnvir = envirBtnText
            envVC.delegate = self
        }
    }
    
    func showControllerForSetting(setting: Setting){
        
        let settingsPopupController = UIViewController()
        settingsPopupController.navigationItem.title = setting.name
        settingsPopupController.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.pushViewController(settingsPopupController, animated: true)
        
    }
    
    // Function to set the background feature flag
    fileprivate func checkBackgroundFeatureValue(){
        let featureFlagValue = LDClient.sharedInstance().boolVariation(backgroundColorKey, fallback: false)
        if featureFlagValue {
            colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)) // default LD dark blue
        }
        else {
            colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1)) // blue
        }
    }
    
    func colorToggles(rgbColor: UIColorFromRGB){
        navigationController?.navigationBar.barTintColor = rgbColor
        tabBarController?.tabBar.barTintColor = rgbColor
        searchBar?.backgroundColor = rgbColor
        mainView?.backgroundColor = rgbColor
        collectionView?.backgroundColor = rgbColor
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

extension ViewController: FlagCellDelegate {
    func switchOnFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1))
        print("switch on")
    }
    func switchOffFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1))
        print("switch off")
    }
}

extension ViewController: EnvironmentsTableDelegate {
    func envirSelected(envirName envir: String?) {
        envirBtnText = envir
    }
}

extension ViewController: ProjectTableDelegate {
    func projectSelected(projectName: String?) {
        projectBtnText = projectName
    }
}
