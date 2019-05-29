//
//  ProjectTableView.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/26/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class ProjectTableView: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    let colorChange = UIColorFromRGB() //Custom calls to change colors from RGB format
    
    // hardcoded for now, this will be fetched from LD later
    var projects = ["Support-service", "Spree Commerece", "api", "Billing application", "Conference Demo", "demo environment", "Empty project", "xamarin-testing"]
    
    var checkedProject = ""
    
    var delegate : ProjectSelectedDelegate?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
            cell.textLabel?.text = projects[indexPath.item]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        if cell.textLabel?.text == checkedProject {
            
            cell.accessoryType = .checkmark
            
        }
        cell.tintColor = UIColor.red
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        delegate?.projectSelected(projectName: projects[indexPath.item])
        
        //CATransaction to set completion action, which is to return back to previous VC
        
        CATransaction.begin()
        tableView.beginUpdates()
        
        CATransaction.setCompletionBlock {
            
            _ = self.navigationController?.popViewController(animated: true)

        }
        
        
        for cellPath in tableView.indexPathsForVisibleRows!{
            
            if cellPath == indexPath{
                continue
            }
            
            tableView.cellForRow(at: cellPath)?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        CATransaction.commit()
    }
}
