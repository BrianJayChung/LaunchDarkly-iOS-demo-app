//
//  SettingsController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 7/8/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    let api = ApiKeys()
    let url = URL(string: "https://app.launchdarkly.com/settings/tokens")!

    @IBOutlet weak var apiKey: UITextField!
    @IBOutlet weak var getApiKeyLink: UITextView!
    
    @IBAction func saveOnEnd(_ sender: Any) {
        saveChecklistItems()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSMutableAttributedString(string: getApiKeyLink.text)
        attributedString.setAttributes([.link: url], range: NSMakeRange(0, 11))
        
        getApiKeyLink.attributedText = attributedString
        getApiKeyLink.isUserInteractionEnabled = true
        getApiKeyLink.isEditable = false
        getApiKeyLink.textAlignment = .center
        getApiKeyLink.font = UIFont(name: getApiKeyLink.font!.fontName, size: 17)
        getApiKeyLink.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let apiKeyString = loadApiKey()
        apiKey.text? = apiKeyString
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("keys.plist")
    }
    
    func saveChecklistItems() {
        let fileManager = FileManager.default
        let path = dataFilePath()
        let apiKeyToEncode = ["api-key": apiKey.text]
        let encoder = PropertyListEncoder()
        /// If file doesn't exist then create a new one with them testData dict, if it does then only change the api-key value
        if !fileManager.fileExists(atPath: path.path) {
            do {
                let data = try encoder.encode(apiKeyToEncode)
                try data.write(to: dataFilePath(),
                               options: Data.WritingOptions.atomic)
            } catch {
                print("Error encoding item\(error.localizedDescription)")
            }
        } else {
            do {
                if let data = try? Data(contentsOf: path) {
                    let decoder = PropertyListDecoder()
                    do {
                        var existData = try decoder.decode([String: String].self, from: data)
                        existData["api-key"] = apiKey.text
                        let newData = try encoder.encode(existData)
                        try newData.write(to: dataFilePath(),
                                       options: Data.WritingOptions.atomic)
                    } catch {
                        print("Error decoding list array: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func loadApiKey() -> String {
        let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let apiKey = plist?.object(forKey: "sdk-key") as! String
        
        return apiKey
    }
    
    
    
    
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
//        cell.tintColor = UIColor.green
////        cell.textLabel?.text = testData[indexPath.row]
//        cell.backgroundColor = .red
//        return cell
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
