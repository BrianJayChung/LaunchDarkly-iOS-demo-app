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
    
    func getData(path: String, requestMethod: HTTPMethod, flagVariation: Bool, environmentKey: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let url = baseUrl.appending(path)
        var parameters: Parameters
        
        let requestMethod = requestMethod
        var headers: [String: String]!
        
        if let apiKey = self.apiKey {
            headers = ["Authorization": apiKey]
        }
        
        if requestMethod == .get {
            parameters = ["": ""]
        } else {
            parameters = [
                "environments" : [
                    environmentKey : [
                        "on" : flagVariation
                    ]
                ]
            ]
        }
        
        print(parameters, url)
        performRequest(url: url, headers: headers, requestMethod: requestMethod, parameters: parameters, completion: completionHandler)
    }
    
    func performRequest(url: String, headers: [String:String], requestMethod: HTTPMethod, parameters: Parameters?, completion: @escaping (Result<[String: Any]>) -> Void ) {

        Alamofire.request(url, method: requestMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            print("Response status code: \(String(describing: response.response?.statusCode))")
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
