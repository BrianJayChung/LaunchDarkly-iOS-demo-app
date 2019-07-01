//
//  LoginTextFieldStyle.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/25/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Foundation

class HSUnderLineTextField: UITextField , UITextFieldDelegate {
    let border = CALayer()
    @IBInspectable open var lineColor : UIColor = UIColor.black {
        didSet {
            border.borderColor = lineColor.cgColor
        }
    }
    
    @IBInspectable open var selectedLineColor : UIColor = UIColor.black {
        didSet {
        }
    }
    
    @IBInspectable open var lineHeight : CGFloat = CGFloat(1.0) {
        didSet {
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    required init?(coder aDecoder: (NSCoder?)) {
        super.init(coder: aDecoder!)
        self.delegate = self
        border.borderColor = lineColor.cgColor
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        self.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        border.borderColor = selectedLineColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        border.borderColor = lineColor.cgColor
    }
}

class UIColorFromRGB: UIColor {
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class NavBarTitleFontStyle: UIFont {
    func fontSizeSetting(fontSize: CGFloat, barBtnItem: UIBarButtonItem, state: UIControl.State){
        let customFontSize = UIFont.boldSystemFont(ofSize: fontSize)
        barBtnItem.setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): customFontSize], for: state)
    }
}

class HighlightTags {
    func generateAttText(targetString: String) -> NSAttributedString? {
        
        let attributed = NSMutableAttributedString(string: targetString)
        // Find all words separated by spaces
        let regexMatch = "[^\\s]+"
        
        do {
            let regex = try NSRegularExpression(pattern: regexMatch, options: [])
            let range = NSRange(location: 0, length: targetString.utf16.count)
            
            for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
                //                attributed.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.red, range: match.range)
                //                attributed.addAttribute(.foregroundColor, value: UIColor.white, range: match.range)
                attributed.addAttributes([NSAttributedString.Key.backgroundColor : UIColor.lightGray, .foregroundColor : UIColor.black], range: match.range)
            }
            
            return attributed
        } catch {
            NSLog("something happend catching express")
            
            return nil
        }
    }
}
