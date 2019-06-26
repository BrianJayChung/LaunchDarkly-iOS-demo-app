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
    
    let sdkKey: String!
    let baseUrl: String!
    let api = ApiKeys()
    
    init() {
        
        self.sdkKey = api.ldApiKey() // previously exposed, new token generated
        self.baseUrl = "https://app.launchdarkly.com/api/v2/"
        
    }
    
    func getData(path: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        
        let headers = ["Authorization": self.sdkKey] as! [String: String]
        let url = baseUrl.appending(path)
        
        performRequest(url: url, headers: headers, completion: completionHandler)
        
    }
    
    func performRequest(url: String, headers: [String:String], completion: @escaping (Result<[String: Any]>) -> Void ) {
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            
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
