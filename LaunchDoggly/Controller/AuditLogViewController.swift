//
//  AuditLogViewController.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/14/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
//protocol AuditLogViewControllerDelegate: class {
//    func auditLogViewControllerDidLoad(
//        _ controller: AuditLogViewController, didLoad response: [String: String]
//    )
//}

class AuditLogViewController: UIViewController, ApiDelegate{
    
    func apiDidFinish(response: DataResponse<Any>?) {
        print("did finish action")
        responseText.text = response?.description
    }
    
    let LdApi = LaunchDarklyApiModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiCall()
//        let headers = ["Authorization": "api-f5cfb140-5537-4c6f-806c-02e4d34a1d20"]
//        getData(url: "https://app.launchdarkly.com/api/v2/projects", headers: headers)
        
        // Do any additional setup after loading the view.
    }
    
    func apiCall() {
        LdApi.getData(path : "flags/support-service") { result in
            switch result {
            case .failure(let error):
                print(error)
            
            case .success(let value):
                self.responseText.text = value.description
            }
        }
    }
    
    @IBOutlet weak var responseText: UITextView!
    
//    func getData(url: String, headers: [String:String]) {
//        Alamofire.request(url, method: .get, headers: headers).responseJSON {
//            response in
//            if response.result.isSuccess {
//                self.responseText.text = response.description
//            } else {
//                print(response)
//            }
//        }
//    }


}
