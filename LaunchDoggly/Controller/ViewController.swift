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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if (velocity.y >= 0) {
            UIView.animate(withDuration: 0.5, delay:0, options: UIView.AnimationOptions(),animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.tabBarController?.tabBar.isHidden = true
                }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: { self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.tabBarController?.tabBar.isHidden = false
        }, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var projectBtnText = "Project"
    var envirBtnText = "Environment"
    
    let cellHeight = 150 // Use for the collectionViewCell height
    let customizeNavBarTitle = NavBarTitleFontStyle()
    
    lazy var navBarLaunchSettings: SettingsPageViewController = {
        let navBarLaunchSettings = SettingsPageViewController()
        navBarLaunchSettings.mainViewController = self
        return navBarLaunchSettings
    }()
    
    // MARK: LaunchDarkly fron-end key
    // This is safe to expose as it can only fetch the flag evaluation outcome
    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    
    //Set feature flag key here
    //fileprivate let menuFlagKey = "show-widgets"
    fileprivate let backgroundColorKey = "background-color"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet weak var projectBarButton: UIButton!
//    @IBOutlet weak var envirBarBtnItem: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var environmentBtn: UIButton!
    @IBOutlet weak var projectButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkBackgroundFeatureValue()
        
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
//        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
        collectionView.register(FlagCell.self, forCellWithReuseIdentifier: "Cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: Logic to handle proj and envir changes
        
        projectButton.setTitle(projectBtnText + " \u{2304}", for: .normal)
        environmentBtn.setTitle(envirBtnText + " \u{2304}", for: .normal)
        
        projectButton.titleLabel?.numberOfLines = 3
        environmentBtn.titleLabel?.numberOfLines = 3
        
        projectButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        environmentBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        environmentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }

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
    
    // MARK: New UI page when clicked on one of the settings
    func showControllerForSetting(setting: Setting){
        
        let settingsPopupController = UIViewController()
        settingsPopupController.navigationItem.title = setting.name
        settingsPopupController.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.pushViewController(settingsPopupController, animated: true)
        
    }
    
    // MARK: Function to set the background feature flag
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
    
    // MARK: collectionView delegates for constructing the flag cell page
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
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
    }
    func switchOffFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1))
    }
}

extension ViewController: EnvironmentsTableDelegate {
    func envirSelected(envirName: String?) {
        envirBtnText = envirName!
    }
}

extension ViewController: ProjectTableDelegate {
    func projectSelected(projectName: String?) {
        projectBtnText = projectName!
    }
}
