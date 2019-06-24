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
    
    @IBOutlet weak var titleText: UITextField!
    
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
    var flagResponseData = LaunchDarklyData()
    
    var envirTitle: String!
    var environmentKey: String!
    var projKey: String!
    var flagJson: JSON?
    
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
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
        
//        collectionView.register(FlagCell.self, forCellWithReuseIdentifier: "Cell")
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SbFlagCell")
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        collectionView.reloadData()
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: CGFloat(cellHeight - 40), right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: Logic to handle proj and envir changes
        FetchFlags()
        projectButton.setTitle(launchDarklyData.projectTitle + " \u{2304}", for: .normal)
        
        projectButton.titleLabel?.numberOfLines = 3
        environmentBtn.titleLabel?.numberOfLines = 3
        
        projectButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        environmentBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        environmentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        apiCall()
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
        return flagResponseData.flagsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var flagText = ""
        let environmentKey = self.environmentKey as String
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlagCell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SbFlagCell", for: indexPath) as! FlagCell
        
        if flagResponseData.flagsList.count > 0 {
            flagText = flagResponseData.flagsList[indexPath.row]["name"].string!
            cell.buttnSwitchOutlet.isOn = flagResponseData.flagsList[indexPath.row]["environments"][environmentKey]["on"].bool!
//            cell.buttnSwitchOutlet.isOn = flagResponseData.flagsList[indexPath.row]["on"].bool!
        }
        
        cell.labelText.text = flagText
//        cell.setupViews(flagCellText: flagText)
        cell.delegate = self
        cell.buttnSwitchOutlet.tag = indexPath.row
        
//        cell.buttonSwitch.tag = indexPath.row // will use this to target each row
//        cell.listenBtnChange()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat(cellHeight))
    }
    
    func setEnvirTitle(){
        environmentBtn.setTitle(envirTitle + " \u{2304}", for: .normal)
    }
    
    func resetEnvirTitle(){
        environmentBtn.setTitle("[ environment ]" + " \u{2304}", for: .normal)
        environmentKey = nil
        self.collectionView.reloadData()
    }
    
    //MARK: -> Network calls
    func apiCall() {
        flagResponseData.flagsList = [JSON]()
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
                        projectRow.envirKeys.append(env["key"].string!)
                    }
                    self.launchDarklyDataList.listOfLaunchDarklyData.append(projectRow)
                }
            }
        }
    }
    
    func FetchFlags(){
        if (projKey != nil) && (environmentKey != nil){
            launchDarklyApi.getData(path : "flags/\(projKey!)?env=\(environmentKey!)") { result in
                switch result {
                case .failure(let error):
                    print(error)
                    
                case .success(let value):
                    let json = JSON(value)
                    //                    self.flagJson = json
                    print("success fetching flags")
                    for (_, subJson) in json["items"] {
                        self.flagResponseData.flagsList.append(subJson)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        // do this when both project and environment objects are available. otherwise return an empty array
    }
    
}

