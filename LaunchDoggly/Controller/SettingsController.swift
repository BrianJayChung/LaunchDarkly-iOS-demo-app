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
    var apiKeyString = [String: String]()

    @IBOutlet weak var apiKey: UITextField!
    @IBOutlet weak var getApiKeyLink: UITextView!
    @IBAction func saveOnEnd(_ sender: Any) {
        print("is it saving here")
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
        loadApiKey()
        apiKey.text? = apiKeyString["sdk-key"]!
        print("Documents folder is \(documentsDirectory())")
        print("Data file path is \(dataFilePath())")
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("keys.plist")
    }
    
    func saveChecklistItems() {
        let testData = ["sdk-key": apiKey.text]
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(testData)
            try data.write(to: dataFilePath(),
                           options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item\(error.localizedDescription)")
        }
    }
    
    func loadApiKey() -> [String: String] {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                apiKeyString = try decoder.decode([String: String].self, from: data)
            } catch {
                print("Error decoding list array: \(error.localizedDescription)")
            }
        }
        return apiKeyString
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
