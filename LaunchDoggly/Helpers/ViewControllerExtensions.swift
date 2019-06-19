//
//  ViewControllerExtensions.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/18/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import LaunchDarkly
import UIKit

extension ViewController: FlagCellDelegate {
    func switchOnFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0.121568, green: 0.164706, blue: 0.266667, alpha: 1))
    }
    func switchOffFlag(_ controller: FlagCell){
        colorToggles(rgbColor: UIColorFromRGB(red: 0, green: 0, blue: 1, alpha: 1))
    }
}

extension ViewController: EnvironmentsTableDelegate {
    func envirSelected(envirName: String?) {
        envirBtnText = envirName!
    }
}

extension ViewController: ProjectTableDelegate {
    func projectSelected(projectName: String?) {
        projectBtnText = projectName!
    }
}

extension ViewController {
    func colorToggles(rgbColor: UIColorFromRGB){
        navigationController?.navigationBar.barTintColor = rgbColor
        tabBarController?.tabBar.barTintColor = rgbColor
        searchBar?.backgroundColor = rgbColor
        mainView?.backgroundColor = rgbColor
        collectionView?.backgroundColor = rgbColor
    }
}

extension ViewController {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let heightLimit = scrollView.contentSize.height - scrollView.bounds.size.height // this is used to determine the scrollview height to prevent botom bounce to hide tab bar
        
        if (self.lastContentOffset < scrollView.contentOffset.y) && (scrollView.contentOffset.y > 0) {
            
            UIView.animate(withDuration: 0.5, delay:0, options: UIView.AnimationOptions(),animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.tabBarController?.tabBar.isHidden = true
            }, completion: nil)
            
        } else if (self.lastContentOffset > scrollView.contentOffset.y) && (scrollView.contentOffset.y < heightLimit) {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: { self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.tabBarController?.tabBar.isHidden = false
            }, completion: nil)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
        
    }
}

extension ViewController {
    // MARK: New UI page when clicked on one of the settings
    func showControllerForSetting(setting: Setting){
        
        let settingsPopupController = UIViewController()
        settingsPopupController.navigationItem.title = setting.name
        settingsPopupController.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
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
