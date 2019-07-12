//
//  ProjEnvNavBarView.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 7/12/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation

class ProjEnvNavBarView: UIViewController {
    /// Setting for project/environment table views
    func navigationSettings(searchController: UISearchController, navigationItem: UINavigationItem) {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.backgroundColor = UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Environment"
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = false
        //  search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
    }
}
