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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainView: UIView!
//    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var environmentBtn: UIButton!
    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func projectBtnPressed(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        performSegue(withIdentifier: "pushToProjects", sender: self)
        // Nav and Tab bar should reappear for the proj table
//        unHideNavTab()
    }
    
    @IBAction func environmentBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToEnvironments", sender: self)
        // Nav and Tab bar should reappear for the env table
//        unHideNavTab()
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
//        view.endEditing(true)
//        navBarLaunchSettings.showRightCorner()
    }
    
    // Data object for the projectDelegate
    var launchDarklyDataFromProjTV = LaunchDarklyData()
    
    // Data object for the flagResponse from fetchFlags
    var flagResponseData = LaunchDarklyData()
    
    // let api = ApiKeys() initializes plist APIs
    var launchDarklyDataList = LaunchDarklyDataList()
    
    var envirTitle: String!
    var environmentKey: String!
    var projKey: String!
    
    var flagJson: JSON?
    
    // MARK: LaunchDarkly fron-end key
    // This is safe to expose as it can only fetch the flag evaluation outcome
    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    
    // Feature flag key for LaunchDarkly use
    let backgroundColorKey = "background-color"
    let launchDarklyApi = LaunchDarklyApiModel()
    
    // Use for the collectionViewCell height
    let cellHeight = 180
    let customizeNavBarTitle = NavBarTitleFontStyle()
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
        navigationItem.searchController = searchController
//        searchController.searchBar.delegate = self
//        searchController.searchResultsUpdater = (self as! UISearchResultsUpdating)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        
        // required for LD to change background color
//        checkBackgroundFeatureValue()
        
        resetEnvirTitle() // Reset the environment title to default
        
        // Set background to LD blue color to prevent flash
//        navigationController?.view.backgroundColor = UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") // hides the navbar shadow
        self.tabBarController?.tabBar.setValue(true, forKey: "hidesShadow")
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(cellHeight - 40), right: 0) // This is needed to add paddings on top and bottom of the collectionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.launchDarklyDataList = LaunchDarklyDataList()
        self.definesPresentationContext = true
        
        activityIndicator.isHidden = true
        
        FetchFlags()
        apiCall()
        
        // MARK: Logic to handle proj and envir changes
        projectButton.setTitle(launchDarklyDataFromProjTV.projectTitle + " \u{2304}", for: .normal)
        
        projectButton.titleLabel?.numberOfLines = 3
        environmentBtn.titleLabel?.numberOfLines = 3
        
        projectButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        environmentBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        projectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        environmentBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.collectionView.indexPathsForVisibleItems.count > 0 {
            collectionView.isScrollEnabled = true
        } else {
            collectionView.isScrollEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToProjects" {
            let projVC = segue.destination as! ProjectTableView
            let backItem = UIBarButtonItem()
            
            backItem.title = "Home"
            navigationItem.backBarButtonItem = backItem
            projVC.checkedProject = launchDarklyDataFromProjTV.projectTitle
            // Setting the LD data list object in the project tableview controller
            projVC.launchDarklyDataList = launchDarklyDataList
            projVC.delegate = self
        }
        
        if segue.identifier == "pushToEnvironments" {
            let envVC = segue.destination as! EnvironmentsTableView
            
            envVC.selectedEnvir.envirName = envirTitle
            // After a project is selected, the data is passed into the launchDarklyDataFromProjTV object. This sets the environments LD data object to the selected prob object
            envVC.launchDarklyData = launchDarklyDataFromProjTV
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
        
        var flagTags = [String]()
        var flagText = ""
        var flagKey = ""
        var descriptionText = ""
        let environmentKey = self.environmentKey as String
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! FlagCell
        
        if flagResponseData.flagsList.count > 0 {
            let item = flagResponseData.flagsList[indexPath.row]
            flagText = item["name"].string!
            descriptionText = item["description"].string!
            flagKey = item["key"].string!
            flagTags = item["tags"].arrayObject! as! [String]
            // Set the button state based on flag is on or off from API response
            cell.buttnSwitchOutlet.isOn = item["environments"][environmentKey]["on"].bool!
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: flagText, attributes: underlineAttribute)
        let newValue = flagTags.joined(separator:"  ")
//        let generateText = HighlightTags()
//        let highlightedTextView = generateText.generateAttText(targetString: newValue)
        
        let textTest: NSAttributedString = {
            let generateText = HighlightTags()
            return generateText.generateAttText(targetString: newValue)!
        }()
        
        cell.tagTextView.attributedText = textTest
        cell.tagTextView.textAlignment = .right
        cell.flagName.attributedText = underlineAttributedString
        cell.flagKey.text = flagKey
        cell.descriptionText.text = descriptionText
        cell.delegate = self
        // Cell.buttnSwitchOutlet.tag = indexPath.row // later use target by tag
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat(cellHeight))
    }
    
    func generateAttText(targetString: String) -> NSAttributedString? {
        let attributed = NSMutableAttributedString(string: targetString)
        let regexMatch = "[^\\s]+"
        
        do {
            let regex = try NSRegularExpression(pattern: regexMatch, options: [])
            let range = NSRange(location: 0, length: targetString.utf16.count)
            
            for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
//                attributed.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.red, range: match.range)
//                attributed.addAttribute(.foregroundColor, value: UIColor.white, range: match.range)
                attributed.addAttributes([NSAttributedString.Key.backgroundColor : UIColor.lightGray, .foregroundColor : UIColor.black], range: match.range)
            }
            
            return attributed
        } catch {
            NSLog("something happend catching express")
            
            return nil
        }
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
                print(error, "no internet")
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
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.activityIndicator.layer.zPosition += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            
            launchDarklyApi.getData(path :
            "flags/\(projKey!)?env=\(environmentKey!)") { result in
                switch result {
                case .failure(let error):
                    print(error, "no internet connection")
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
