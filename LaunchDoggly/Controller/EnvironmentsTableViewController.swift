//
//  ProjectTableView.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/26/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class EnvironmentsTableView: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    let colorChange = UIColorFromRGB() // Custom calls to change colors from RGB format

    // hardcoded for now, this will be fetched from LD later
    
    var environments = ["production", "testing", "beta", "pre-production", "QA-server", "product-team", "demo environment", "Empty project", "xamarin-testing", "Some super very long environemnt name"]
    
    var delegate : EnvirSelectedDelegate?
    var selectedEnvir = ""
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return environments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "environmentCell", for: indexPath)
        cell.textLabel?.text = environments[indexPath.item]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        if cell.textLabel?.text == selectedEnvir {
            cell.accessoryType = .checkmark
        }
        
        cell.tintColor = UIColor.red
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        delegate?.envirSelected(envirName: environments[indexPath.item] )
        
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
