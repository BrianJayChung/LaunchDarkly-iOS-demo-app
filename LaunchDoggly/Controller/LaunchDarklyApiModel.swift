//
//  LaunchDarklyDataModel.swift
//  LaunchDoggly
//
//  Created by Brian Chung on 6/17/19.
//  Copyright © 2019 Bchung Dev. All rights reserved.
//

import Alamofire
import SwiftyJSON

class LaunchDarklyApiModel {
    let apiKey: String!
    let baseUrl: String!
    let api = ApiKeys()
    let settingsController = SettingsController()
    
    init() {
        self.apiKey = settingsController.loadApiKey()["api-key"]
        self.baseUrl = "https://app.launchdarkly.com/api/v2/"
    }
    
    func getData(path: String, requestMethod: HTTPMethod, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let url = baseUrl.appending(path)
        let requestMethod = requestMethod
        var headers = ["Authorization": "123"] as [String: String]
        
        if let apiKey = self.apiKey {
            headers = ["Authorization": apiKey] as [String: String]
        }
        
        performRequest(url: url, headers: headers, requestMethod: requestMethod, completion: completionHandler)
    }
    
    func performRequest(url: String, headers: [String:String], requestMethod: HTTPMethod, completion: @escaping (Result<[String: Any]>) -> Void ) {
        
        let parameters = [
            "environments": [
                "brian": [
                    "on": false
                ]
            ]
        ]


        Alamofire.request(url, method: requestMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            print("Response status code: \(String(describing: response.response?.statusCode))")
            print(parameters)
            switch response.result {
            case .success(let value as [String: Any]):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            default:
                fatalError("received non-dict JSON response")
            }
        }
    }
    
}

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
