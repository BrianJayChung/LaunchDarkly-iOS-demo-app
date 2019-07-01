//
//  ProjectTableView.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/26/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ProjectTableDelegate {
    func projectTableDelegate(launchDarklyDataItem: LaunchDarklyData, projectKey: String)
}

class ProjectTableView: UITableViewController, UISearchBarDelegate {
    // Search filter list
    var filteredProjects = [LaunchDarklyData]()
    
    var checkedProject: String?
    var activityIndicator = UIActivityIndicatorView()
    var launchDarklyDataList: LaunchDarklyDataList!
    var selectedProject = LaunchDarklyData()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var delegate: ProjectTableDelegate?
    
    @IBOutlet weak var blueScreen: UIView!
    @IBOutlet weak var loadingViewScreen: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        // Navigation Settings, including searchcontroller
        navigationSettings()
        // Display a view when there is no connection
        noConnectionView()
//        blueScreen.bounds = self.view.bounds
//        blueScreen.center = self.view.center
//        blueScreen.alpha = 0.4

//        self.view.addSubview(blueScreen)

//        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
//            self.blueScreen.alpha = 0
//        }) { (success) in
//            self.blueScreen.removeFromSuperview()
//        }
//
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.searchController?.removeFromParent()
        self.navigationItem.searchController?.isActive = false
    }
    
    func navigationSettings() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.backgroundColor = UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Project"
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = false
        //  search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
        self.definesPresentationContext = true
    }

    func loadingView() {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        let strLabel = UILabel(frame: CGRect(x: 48, y: 0, width: 180, height: 46))
        
        strLabel.text = "No Internet Connection"
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.9)
        
        effectView.frame = CGRect(x: 0, y: 0 , width: 220, height: 46)
        effectView.center = view.center
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        activityIndicator.style = .white
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        effectView.tag = 12345
        
        self.navigationController?.view.addSubview(effectView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredProjects.count
        }
        
        return launchDarklyDataList.listOfLaunchDarklyData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        let ldData: LaunchDarklyData
            
        if Connectivity.isConnectedToInternet() {
            if isFiltering(){
                ldData = filteredProjects[indexPath.row]
            } else {
                ldData = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row]
            }
            
            cell.textLabel?.text = ldData.projectTitle
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.tintColor = UIColor.red
            
            if ldData.projectIsChecked {
                selectedProject = ldData
            }
            
            configureCheckmark(for: cell, with: ldData)
        }
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ldData: LaunchDarklyData
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if isFiltering(){
                ldData = filteredProjects[indexPath.row]
            } else {
                ldData = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row]
            }
            
            let item = ldData
            // When a project is selected pass the selected LD object to viewcontroller and the project key
            delegate?.projectTableDelegate(launchDarklyDataItem: item, projectKey: item.projectKey!)
            
            // the below logic will handle duplication of checkmarks as well as checkmark being checked off when selected on an item with existing checkmark
            // if the current flag is not the previously selected flag, do the below
            if item != selectedProject {
                // if item is blank, this will make isChecked = true
                item.toggleProjectChecked()
                // this changes the isChecked property for previously selected flag
                selectedProject.toggleProjectChecked()
            }
            
            configureCheckmark(for: cell, with: item)
        }
        
        //CATransaction to set completion action, which is to return back to previous VC
        CATransaction.begin()
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
            _ = self.navigationController?.popViewController(animated: true) // used for "show"
            //            _ = self.dismiss(animated: true, completion: nil) // used due to present modally
        }
        
        // logic to deselect every row but the one with the checkmark
        for cellPath in tableView.indexPathsForVisibleRows! {
            if cellPath == indexPath {
                continue
            }
            
            tableView.cellForRow(at: cellPath)?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    // MARK: -> Search bar helper functions
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredProjects = launchDarklyDataList.listOfLaunchDarklyData.filter({( ldData : LaunchDarklyData) -> Bool in
            return ldData.projectTitle.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: LaunchDarklyData) {
        if item.projectIsChecked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    func noConnectionView() {
        if !Connectivity.isConnectedToInternet() {
            loadingView()
        } else {
            for subview in (self.navigationController?.view.subviews)! {
                if (subview.viewWithTag(12345) != nil) {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

extension ProjectTableView: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
