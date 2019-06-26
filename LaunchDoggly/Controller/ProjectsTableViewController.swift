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
    
    override func viewDidLoad() {
        blueScreen.bounds = self.view.bounds
        blueScreen.center = self.view.center
        blueScreen.alpha = 0.4
        
        self.view.addSubview(blueScreen)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.blueScreen.alpha = 0
        }) { (success) in
            self.blueScreen.removeFromSuperview()
        }
        
        super.viewDidLoad()
        
//        self.showSpinner(onView: self.view, offSet: 0)
        
        noConnectionView()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    let colorChange = UIColorFromRGB() //Custom calls to change colors from RGB format
    
    @IBOutlet weak var blueScreen: UIView!
    
    @IBOutlet weak var loadingViewScreen: UIView!
    
    var checkedProject : String?
    var activityIndicator = UIActivityIndicatorView()
    var delegate : ProjectTableDelegate?
    var launchDarklyDataList: LaunchDarklyDataList!
    var selectedProject = LaunchDarklyData()
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let strLabel = UILabel(frame: CGRect(x: 48, y: 0, width: 180, height: 46))
    
    func loadingView() {
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
            return launchDarklyDataList.listOfLaunchDarklyData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        
        if Connectivity.isConnectedToInternet() {
            cell.textLabel?.text = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row].projectTitle
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.tintColor = UIColor.red
            
            let item = launchDarklyDataList.listOfLaunchDarklyData[indexPath.row]
            if item.projectIsChecked {
                selectedProject = item
            }
            configureCheckmark(for: cell, with: item)
        }
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

