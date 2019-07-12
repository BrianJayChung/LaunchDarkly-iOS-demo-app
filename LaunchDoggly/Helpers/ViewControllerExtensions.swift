//
//  ViewControllerExtensions.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/18/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import LaunchDarkly
import UIKit
import SwiftyJSON

extension ViewController: FlagCellDelegate {
    func switchOnFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1))
    }
    func switchOffFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1))
    }
}

extension ViewController: EnvironmentsTableDelegate {
    func environmentsTableDelegate(envirName: String, envirKey: String) {
        environmentKey = envirKey
        envirTitle = envirName
        setEnvirTitle()
    }
}

extension ViewController: ProjectTableDelegate {
    func projectTableDelegate(launchDarklyDataItem: LaunchDarklyData, projectKey: String) {
        launchDarklyDataFromProjTV = launchDarklyDataItem
        projKey = projectKey
        environmentBtn.isHidden = false
        resetEnvirTitle()
    }
}

extension ViewController {
    func colorToggles(rgbColor: UIColorFromRGB){
        navigationController?.navigationBar.barTintColor = rgbColor
        tabBarController?.tabBar.barTintColor = rgbColor
//        searchBar?.backgroundColor = rgbColor
        mainView?.backgroundColor = rgbColor
        collectionView?.backgroundColor = rgbColor
    }
}

// MARK: LaunchDarkly function to set the background feature flag
extension ViewController {
    func checkBackgroundFeatureValue() {
        let featureFlagValue = LDClient.sharedInstance().boolVariation(backgroundColorKey, fallback: false)
        
        if featureFlagValue {
            colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1)) // default LD dark blue
        } else {
            colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1)) // blue
        }
    }
}

// MARK: -> using regex to determine spacing between tags to for highlighting
extension ViewController {
    func generateAttText(targetString: String) -> NSAttributedString? {
        
        let attributed = NSMutableAttributedString(string: targetString)
        let regexMatch = "[^\\s]+"
        
        do {
            let regex = try NSRegularExpression(pattern: regexMatch, options: [])
            let range = NSRange(location: 0, length: targetString.utf16.count)
            
            for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
                attributed.addAttributes([NSAttributedString.Key.backgroundColor : UIColor.lightGray, .foregroundColor : UIColor.black], range: match.range)
            }
            
            return attributed
        } catch {
            NSLog("something happend catching express")
            
            return nil
        }
    }
}

// MARK: New UI page when clicked on one of the settings
extension ViewController {
    func showControllerForSetting(setting: Setting) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let settingsPopupController = storyBoard.instantiateViewController(withIdentifier: "SettingsPage") as! SettingsController
        settingsPopupController.navigationItem.title = setting.name
        navigationController?.pushViewController(settingsPopupController, animated: true)
    }
}

// LaunchDarkly SDK delegate
extension ViewController: ClientDelegate {
    func featureFlagDidUpdate(_ key: String) {
        if key == backgroundColorKey {
            checkBackgroundFeatureValue()
        }
    }
}

//MARK: -> Network calls
extension ViewController {
    func launchDarklyApiCall() {
        let launchDarklyApi = LaunchDarklyApiModel()
       /// This needs to get called to clear out the collection view, to empty view on project reselect, as well as avoiding non-existent key to be called
//        flagResponseData.flagsList = [JSON]()
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
}

extension ViewController {
    // This function gets triggered when both proj/envir are selected
    func launchDarklyfetchFlags() {
        let launchDarklyApi = LaunchDarklyApiModel()
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

// MARK: - UISearchResultsUpdating Delegate
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
