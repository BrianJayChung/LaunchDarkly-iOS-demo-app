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

class ProjectTableView: UITableViewController {
    
    var checkedProject : String?
    
    var activityIndicator = UIActivityIndicatorView()
    
    var delegate : ProjectTableDelegate?
    
    var launchDarklyDataList: LaunchDarklyDataList!
    
    var selectedProject = LaunchDarklyData()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadingView()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
      

    }
    
    func loadingView() {
        
        activityIndicator.bounds = self.view.bounds
        activityIndicator.center = self.view.center
        
        activityIndicator.style = .gray
        
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    //    let ldApi = LaunchDarklyApiModel()
    let colorChange = UIColorFromRGB() //Custom calls to change colors from RGB format
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launchDarklyDataList.listOfLaunchDarklyData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        
        cell.textLabel?.text = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row].projectTitle
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.tintColor = UIColor.red
        
        let item = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row]
        
        if item.projectIsChecked {
            selectedProject = item
        }
        
        configureCheckmark(for: cell, with: item)
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.view.willRemoveSubview(activityIndicator)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            let item = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row]
            
            delegate?.projectTableDelegate(launchDarklyDataItem: item, projectKey: item.projectKey!) // When a project is selected pass the selected LD object to viewcontroller and the project key
            
            //MARK: -> the below logic will handle duplication of checkmarks as well as checkmark being checked off when selected on an item with existing checkmark
            
            if item != selectedProject { // if the current flag is not the previously selected flag, do the below
                
                item.toggleProjectChecked() // if item is blank, this will make isChecked = true
                selectedProject.toggleProjectChecked() // this changes the isChecked property for previously selected flag
                
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
        
        for cellPath in tableView.indexPathsForVisibleRows!{ // logic to deselect every row but the one with the checkmark
            
            if cellPath == indexPath {
                continue
            }
            
            tableView.cellForRow(at: cellPath)?.accessoryType = .none
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        CATransaction.commit()
        
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: LaunchDarklyData) {
        
        if item.projectIsChecked {
            
            cell.accessoryType = .checkmark
            
        } else {
            
            cell.accessoryType = .none
            
        }
    }
}

