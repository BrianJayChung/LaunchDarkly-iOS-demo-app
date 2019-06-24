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
    
    var launchDarklyDataFromProjTV = LaunchDarklyData() // Data object for the projectDelegate
    var flagResponseData = LaunchDarklyData() // Data object for the flagResponse from fetchFlags
    
    var envirTitle: String!
    var environmentKey: String!
    var projKey: String!
    var flagJson: JSON?
    
    
    // MARK: LaunchDarkly fron-end key
    // This is safe to expose as it can only fetch the flag evaluation outcome
    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    
    let backgroundColorKey = "background-color" // Feature flag key for LaunchDarkly use
    
    let launchDarklyApi = LaunchDarklyApiModel()
    
    let launchDarklyDataList = LaunchDarklyDataList() // let api = ApiKeys() initializes plist APIs
    
    let cellHeight = 150 // Use for the collectionViewCell height
    let customizeNavBarTitle = NavBarTitleFontStyle()
    
    lazy var navBarLaunchSettings: SettingsPageViewController = {
        let navBarLaunchSettings = SettingsPageViewController()
        navBarLaunchSettings.mainViewController = self
        return navBarLaunchSettings
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        checkBackgroundFeatureValue() // required for LD
        resetEnvirTitle() // Reset the environment title to default
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: CGFloat(cellHeight - 40), right: 0) // This is needed to add paddings on top and bottom of the collectionView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // API call to get flags after proj/envir are selected
        FetchFlags()
        
        // MARK: Logic to handle proj and envir changes
        projectButton.setTitle(launchDarklyDataFromProjTV.projectTitle + " \u{2304}", for: .normal)
        
        projectButton.titleLabel?.numberOfLines = 3
        environmentBtn.titleLabel?.numberOfLines = 3
        
        projectButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        environmentBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        environmentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        apiCall()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pushToProjects" {
            
            let projVC = segue.destination as! ProjectTableView
            let backItem = UIBarButtonItem()
            backItem.title = "Home"
            navigationItem.backBarButtonItem = backItem
            
            projVC.checkedProject = launchDarklyDataFromProjTV.projectTitle
            projVC.launchDarklyDataList = launchDarklyDataList // Setting the LD data list object in the project tableview controller
            
            projVC.delegate = self
            
        }
        
        if segue.identifier == "pushToEnvironments" {
            
            let envVC = segue.destination as! EnvironmentsTableView
            
            envVC.selectedEnvir.envirName = envirTitle
            envVC.launchDarklyData = launchDarklyDataFromProjTV // After a project is selected, the data is passed into the launchDarklyDataFromProjTV object. This sets the environments LD data object to the selected prob object
            
            envVC.delegate = self
            
        }
    }
    
    // MARK: Function to set the background feature flag
    func checkBackgroundFeatureValue() {
        
        let featureFlagValue = LDClient.sharedInstance().boolVariation(backgroundColorKey, fallback: false)
        
        if featureFlagValue {
            
            colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)) // default LD dark blue
        } else {
            
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
        var descriptionText = ""
        let environmentKey = self.environmentKey as String
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! FlagCell
        
        let item = flagResponseData.flagsList[indexPath.row]
        
        if flagResponseData.flagsList.count > 0 {
            
            flagText = item["name"].string!
            descriptionText = item["description"].string!
            cell.buttnSwitchOutlet.isOn = item["environments"][environmentKey]["on"].bool! // Set the button state based on flag is on or off from API response
        }
        
        // Set flag text/description for each cell
        cell.flagName.text = flagText
        cell.descriptionText.text = descriptionText

        cell.delegate = self
        // Cell.buttnSwitchOutlet.tag = indexPath.row // later use target by tag
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
                    
                    let projectRow = LaunchDarklyData() // create the top-level LD object
                    
                    projectRow.projectTitle = subJson["name"].string! // set the proj title
                    projectRow.projectKey = subJson["key"].string! // set the pro jkey
                    
                    for (_, env) in subJson["environments"] {
                        // Each project has multiple environments
                        let envirRow = LaunchDarklyData() // create 2nd level LD object for the environments
                        
                        envirRow.envirName = env["name"].string! // set the attribute name
                        envirRow.envirKey = env["key"].string! // set the attribute key
                        
                        projectRow.environmentsList.append(envirRow) // store the object into the top-level LD object which has an array to hold these
                        
                    }
                    
                    self.launchDarklyDataList.listOfLaunchDarklyData.append(projectRow) // Append the projectRow object into the LD data list object
                    
                }
            }
        }
    }
    
    // This function gets triggered when both proj/envir are selected
    func FetchFlags() {
        
        if (projKey != nil) && (environmentKey != nil) {
            
            launchDarklyApi.getData(path :
            "flags/\(projKey!)?env=\(environmentKey!)") { result in
                
                switch result {
                    
                case .failure(let error):
                    print(error)
                    
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    print("success fetching flags")
                    for (_, subJson) in json["items"] {
                        
                        self.flagResponseData.flagsList.append(subJson)
                        self.collectionView.reloadData() // reload the collection view after api is fetched
                        
                    }
                }
            }
        }
    }
}

