//
//  popOverViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/9/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class AboutUsView: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var viewPinch: UIView!
    
    var blackView = UIView()
    var isLandscape : Bool = UIDevice.current.orientation.isLandscape
    var width : CGFloat?
    var height: CGFloat?
    var pinchGesture  = UIPinchGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeightAndWidth()
        addTouchGesture()
//        addPinchGesture()
    }
    
//    @objc func pinchedView(sender:UIPinchGestureRecognizer){
//        self.view.bringSubviewToFront(viewPinch)
//        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
//        sender.scale = 1.0
//    }
//
//    func addPinchGesture(){
//        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
//        viewPinch.isUserInteractionEnabled = true
//        viewPinch.addGestureRecognizer(pinchGesture)
//    }
    
    func addTouchGesture() {
        showBlackView()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    func showBlackView(){
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.8)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            blackView.translatesAutoresizingMaskIntoConstraints = false
            
            window.addSubview(blackView)
            
            UIView.animate(withDuration: 0, animations: {
                self.blackView.backgroundColor = .clear
            })
        }
    }
    
    func setHeightAndWidth(){
        if isLandscape {
            width = view.frame.width
            height = view.frame.height
        } else {
            width = view.frame.height
            height = view.frame.width
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        addPinchGesture()
        showBlackView()
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.2, animations: {
            self.blackView.alpha = 0
        })
        closeButtonPressed()
    }

    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
