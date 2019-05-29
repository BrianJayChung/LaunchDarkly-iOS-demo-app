//
//  VideCell.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/14/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class SettingCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        
        didSet {
            
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
            
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            
            iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
        }
    }
    
    var setting: Setting? {
        
        didSet{
            
            nameLabel.text = setting?.name
            
            if let imageName = setting?.imageName {
                iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor.darkGray
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupViews()
        
    }
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews(){
        
        addSubview(iconImageView)
        addSubview(nameLabel)
        
        addConstraintsWithFormat(format: "H:|-25-[v0(-5)]-35-[v1]|", views: iconImageView, nameLabel)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-|", views: nameLabel)
        
        addConstraintsWithFormat(format: "V:[v0(20)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
