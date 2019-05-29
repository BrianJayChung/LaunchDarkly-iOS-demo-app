//
//  TableViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 5/21/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

struct CellData {
    let image : UIImage?
    let message : String?
}

class SdkTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        
        data = [CellData.init(image: UIImage(named: "android"), message: "Android\n"), CellData.init(image: UIImage(named: "browser"), message: "Java\n"), CellData.init(image: UIImage(named: "javascript"), message: "Javascript\n"), CellData.init(image: UIImage(named: "php"), message: "PHP\n"), CellData.init(image: UIImage(named: "swift"), message: "Swift\n"), CellData.init(image: UIImage(named: "ruby"), message: "Ruby\n"),CellData.init(image: UIImage(named: "nodejs"), message: "NodeJS\n"), CellData.init(image: UIImage(named: "reactnative"), message: "React Native\n")]
        
        self.tableView.register(SdkTableViewCell.self, forCellReuseIdentifier: "sdkcell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 400
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sdkcell") as! SdkTableViewCell
        cell.mainImage = data[indexPath.row].image
        cell.message = data[indexPath.row].message
        cell.isUserInteractionEnabled = true
        cell.layoutSubviews()
        
        return cell
    }
}
