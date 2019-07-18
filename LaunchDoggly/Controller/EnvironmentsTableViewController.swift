//
//  ProjectTableView.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/26/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

protocol EnvironmentsTableDelegate{
    func environmentsTableDelegate(envirName: String, envirKey: String)
}

class EnvironmentsTableView: UITableViewController, UISearchBarDelegate {
    
    // Custom calls to change colors from RGB format
    let colorChange = UIColorFromRGB()
    let searchController = UISearchController(searchResultsController: nil)
    let navBarSettings = ProjEnvNavBarView()
    
    var delegate : EnvironmentsTableDelegate?
    var selectedEnvir = LaunchDarklyData()
    var launchDarklyData: LaunchDarklyData!
    var filteredProjects = [LaunchDarklyData]()
    var launchDarklyDataList: LaunchDarklyDataList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarSettings.navigationSettings(searchController: searchController, navigationItem: navigationItem)
        /// Setting search bar delegates
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

//    func navigationSettings() {
//        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//
//        navigationController?.navigationBar.titleTextAttributes = textAttributes
//        navigationController?.navigationBar.backgroundColor = UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)
//        searchController.searchBar.delegate = self
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search Environment"
//
//        navigationItem.searchController = searchController
//        navigationController?.navigationBar.prefersLargeTitles = false
//        //  search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
//        self.definesPresentationContext = true
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredProjects.count
        }
        
        return launchDarklyData.environmentsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "environmentCell", for: indexPath)
        let item = launchDarklyData.environmentsList[indexPath.item]
        let ldData: LaunchDarklyData
        
        if isFiltering(){
            ldData = filteredProjects[indexPath.row]
        } else {
            ldData = launchDarklyData.environmentsList[indexPath.row]
        }
        
        if item.environmentIsChecked {
        // Track currently selected item
            selectedEnvir = ldData
        }
        // This is to determine whether a cell should be chekced
        configureCheckmark(for: cell, with: ldData)
        
        cell.textLabel?.text = ldData.envirName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.tintColor = UIColor.red
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ldData: LaunchDarklyData
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if isFiltering() {
                ldData = filteredProjects[indexPath.row]
            } else {
                ldData = launchDarklyData.environmentsList[indexPath.row]
            }
            
            let item = ldData
            
            if item != selectedEnvir {
                item.toggleEnvironmentChecked()
                selectedEnvir.toggleEnvironmentChecked()
            }
            configureCheckmark(for: cell, with: item)
            
            // Calls the environmentsTable delegate when an envir is selected, this passes the envirName and key to viewcontroller to make the API call
            delegate?.environmentsTableDelegate(envirName: item.envirName!, envirKey: item.envirKey!)
        }
        
        // CATransaction to set completion action, which is to return back to previous VC
        CATransaction.begin()
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
             _ = self.navigationController?.popViewController(animated: true)
//            _ = self.dismiss(animated: true, completion: nil)
        }

        for cellPath in tableView.indexPathsForVisibleRows! { // Logic to not un-toggle a row that is already chcked, otherwise untoggle it
            if cellPath == indexPath{
                continue
            }
            
            tableView.cellForRow(at: cellPath)?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: LaunchDarklyData) {
        if item.environmentIsChecked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    // MARK: -> Search bar helper functions
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredProjects = launchDarklyData.environmentsList.filter({( ldData : LaunchDarklyData) -> Bool in
            return ldData.envirName!.lowercased().contains(searchText.lowercased())
        })

        tableView.reloadData()
    }
}

extension EnvironmentsTableView: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
