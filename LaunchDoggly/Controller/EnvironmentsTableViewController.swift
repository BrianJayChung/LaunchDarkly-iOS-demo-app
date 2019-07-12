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

class EnvironmentsTableView: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
        
//        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.searchController?.removeFromParent()
        self.navigationItem.searchController?.isActive = false
    }
    // Custom calls to change colors from RGB format
    let colorChange = UIColorFromRGB()
    
    var delegate : EnvironmentsTableDelegate?
    var selectedEnvir = LaunchDarklyData()
    var launchDarklyData: LaunchDarklyData!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launchDarklyData.environmentsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "environmentCell", for: indexPath)
        let item = launchDarklyData.environmentsList[indexPath.item]
        
        if item.environmentIsChecked {
        // Track currently selected item
            selectedEnvir = item
        }
        // This is to determine whether a cell should be chekced
        configureCheckmark(for: cell, with: item)
        cell.textLabel?.text = item.envirName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.tintColor = UIColor.red
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = launchDarklyData.environmentsList[indexPath.item]
            
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
    
}
