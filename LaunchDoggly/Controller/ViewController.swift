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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var environmentBtn: UIButton!
    @IBOutlet weak var projectBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    @IBAction func projectBtnPressed(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        performSegue(withIdentifier: "pushToProjects", sender: self)
    }
    
    @IBAction func environmentBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pushToEnvironments", sender: self)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
//        view.endEditing(true)
        navBarLaunchSettings.showRightCorner()
    }
    
    // Data object for the projectDelegate
    var launchDarklyDataFromProjTV = LaunchDarklyData()
    // Data object for the flagResponse from fetchFlags
    var flagResponseData = LaunchDarklyData()
    // let api = ApiKeys() initializes plist APIs
    var launchDarklyDataList = LaunchDarklyDataList()
    
    var filterFlagResponse = [JSON]()
    var flagJson: JSON?
    
    var envirTitle: String!
    var environmentKey: String!
    var projKey: String?
    
    /// LaunchDarkly fron-end key, safe to expose as it can only fetch the flag evaluation outcome
    let config = LDConfig.init(mobileKey: "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6")
    
    /// Feature flag key for LaunchDarkly use
    let backgroundColorKey = "background-color"
    let launchDarklyApi = LaunchDarklyApiModel()
    
    /// Use for the collectionViewCell height
    let cellHeight = 180
    let customizeNavBarTitle = NavBarTitleFontStyle()
    
    /// Instantiating searchController
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var navBarLaunchSettings: SettingsPopupViewController = {
        let navBarLaunchSettings = SettingsPopupViewController()
        
        navBarLaunchSettings.mainViewController = self
        return navBarLaunchSettings
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        /// Adding search controller to navbar
        navigationItem.searchController = searchController
        /// Configure search controller
        searchControllerSetup()
        /// Configure collectionview
        collectionViewSetup()
        /// Disable shadows
        navTabBarShadow()
        /// required for LD to change background color
        // checkBackgroundFeatureValue()
        
        /// Reset the environment title to default
        resetEnvirTitle()
        /// hides the navbar shadow
        self.hideKeyboardWhenTappedAround()
        
        LDClient.sharedInstance().delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// This is needed to add paddings on top and bottom of the collectionView
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: CGFloat(cellHeight - 40), right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.isScrollEnabled = false
        /// Reset this to empty to avoid duplications
        self.launchDarklyDataList = LaunchDarklyDataList()
        self.flagResponseData.flagsList = [JSON]()
        activityIndicator.isHidden = true
        /// This is called when both proj/env are sellected
//        flagResponseData.flagsList = [JSON]()
        launchDarklyfetchFlags()
        
        launchDarklyApiCall()
        
        projEnvBtnSettings(button: projectBtn)
        projEnvBtnSettings(button: environmentBtn)
        /// Logic to handle proj and envir changes
        projectBtn.setTitle(launchDarklyDataFromProjTV.projectTitle + " \u{2304}", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// placeholder value of flag count each time the page reloads
//        searchController.searchBar.placeholder? = "Search \(self.flagResponseData.flagsList.count) feature flags"
        self.collectionView.performBatchUpdates(nil, completion: {
            (result) in

            self.searchController.searchBar.placeholder? = "Search \(self.flagResponseData.flagsList.count) feature flags"
            
            print(self.collectionView.indexPathsForVisibleItems.count)
            
            print(self.flagResponseData.flagsList.count)
            if self.collectionView.indexPathsForVisibleItems.count > 0 {
                self.collectionView.isScrollEnabled = true
            } else {
                self.collectionView.isScrollEnabled = false
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToProjects" {
            let projVC = segue.destination as! ProjectTableView
            
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
    
    // MARK: collectionView delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filterFlagResponse.count
        }
        
        return flagResponseData.flagsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var flagTags = [String]()
        var flagText: String?
        var flagKey: String?
        var flagDescription: String?
        let item: JSON
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! FlagCell
        cell.delegate = self
        
        /// If the collection view is not empty, do the below
        if flagResponseData.flagsList.count > 0 {
            self.collectionView.isScrollEnabled = true
            /// If search bar is open use the filteredProjects array
            if isFiltering() {
                item = filterFlagResponse[indexPath.row]
            } else {
                item = flagResponseData.flagsList[indexPath.row]
            }
            
            flagText = item["name"].string!
            flagDescription = item["description"].string!
            flagKey = item["key"].string!
            flagTags = item["tags"].arrayObject! as! [String]
            
            if let environmentKey = self.environmentKey {
                print(environmentKey)
                cell.buttnSwitchOutlet.isOn = item["environments"][environmentKey]["on"].bool!
            }
            // Set the button state based on flag is on or off from API response
            
        }
        
        let tagsSpaced = flagTags.joined(separator:"  ")
        
        let tagsHighlighted: NSAttributedString = {
            let generateText = HighlightTags()
            return generateText.generateAttText(targetString: tagsSpaced)!
        }()
        
        cell.tagTextView.attributedText = tagsHighlighted
        cell.tagTextView.textAlignment = .right
        cell.flagName.text = flagText
        cell.flagKey.text = flagKey
        cell.descriptionText.text = flagDescription
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.95, height: CGFloat(cellHeight))
    }
    
    // MARK: - Environment settings
    func setEnvirTitle(){
        environmentBtn.setTitle(envirTitle + " \u{2304}", for: .normal)
    }
    
    func resetEnvirTitle(){
        environmentBtn.setTitle("[ environment ]" + " \u{2304}", for: .normal)
        environmentKey = nil
        
        self.collectionView.reloadData()
    }
    // MARK : Searchbar delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleBtns(true)
        collectionHeightConstraint.constant = 50
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.collectionHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.collectionHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            self.toggleBtns(false)
        })
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterFlagResponse = flagResponseData.flagsList.filter({( ldData : JSON) -> Bool in
            return ldData["name"].string!.lowercased().contains(searchText.lowercased())
        })
        
        collectionView.reloadData()
    }
    
    func searchControllerSetup() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = (self as UISearchResultsUpdating)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func collectionViewSetup() {
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
    }
    
    func navTabBarShadow() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.tabBarController?.tabBar.setValue(true, forKey: "hidesShadow")
    }
    
    // MARK: - Toggle the items below navbar
    func toggleBtns(_ toogle: Bool){
        projectBtn.isHidden = toogle
        environmentBtn.isHidden = toogle
        arrowBtn.isHidden = toogle
    }
    
    // MARK: - Project/environment button settings
    func projEnvBtnSettings(button: UIButton) {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.titleLabel?.numberOfLines = 2
    }
    
}





