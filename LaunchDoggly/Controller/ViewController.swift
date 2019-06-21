//
//  ViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/9/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//
import UIKit
import LaunchDarkly
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    var lastContentOffset: CGFloat = 0
    
    var launchDarklyData = LaunchDarklyData()
    
    var envirTitle: String!
    
//    let api = ApiKeys() // initializes plist APIs
    let launchDarklyDataList = LaunchDarklyDataList()
    
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
    let backgroundColorKey = "background-color"
    
    let launchDarklyApi = LaunchDarklyApiModel()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
//        navigationController?.tabBarController?.tabBar.isHidden = true
        checkBackgroundFeatureValue()
        resetEnvirTitle()
        
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
        
        collectionView.register(FlagCell.self, forCellWithReuseIdentifier: "Cell")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(cellHeight), right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: Logic to handle proj and envir changes
        
        projectButton.setTitle(launchDarklyData.projectTitle + " \u{2304}", for: .normal)
        
        projectButton.titleLabel?.numberOfLines = 3
        environmentBtn.titleLabel?.numberOfLines = 3
        
        projectButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        environmentBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        environmentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        apiCall()
    }
    
    func setEnvirTitle(){
        environmentBtn.setTitle(envirTitle + " \u{2304}", for: .normal)
    }
    
    func resetEnvirTitle(){
        environmentBtn.setTitle("[ environment ]" + " \u{2304}", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "pushToProjects" {
            let projVC = segue.destination as! ProjectTableView
            let backItem = UIBarButtonItem()
            backItem.title = "Home"
            navigationItem.backBarButtonItem = backItem
            projVC.checkedProject = launchDarklyData.projectTitle
            projVC.launchDarklyDataList = launchDarklyDataList
            projVC.delegate = self
        }
        if segue.identifier == "pushToEnvironments" {
            let envVC = segue.destination as! EnvironmentsTableView
            envVC.selectedEnvir = envirTitle
            envVC.launchDarklyData = launchDarklyData
            envVC.delegate = self
        }
    }
    
    // MARK: Function to set the background feature flag
    func checkBackgroundFeatureValue(){
        let featureFlagValue = LDClient.sharedInstance().boolVariation(backgroundColorKey, fallback: false)
        if featureFlagValue {
            colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)) // default LD dark blue
        }
        else {
            colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1)) // blue
        }
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

    //MARK: -> Network calls
    
    func apiCall() {
        launchDarklyApi.getData(path : "projects") { result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let value):
                let json = JSON(value)
                for (_, subJson) in json["items"] {
                    
                    let projectRow = LaunchDarklyData()
                    
                    projectRow.projectTitle = subJson["name"].string!
                    projectRow.projectKey = subJson["key"].string!
                    for (_, env) in subJson["environments"] {
                        
                        projectRow.environmentsList.append(env["name"].string!)
                        
                    }
                    self.launchDarklyDataList.listOfLaunchDarklyData.append(projectRow)
//                    print(projectRow.environmentsList)
                }
            }
        }
    
    }
    
}

