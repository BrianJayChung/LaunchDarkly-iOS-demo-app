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
    
    let headers = ["Authorization": "api-f5cfb140-5537-4c6f-806c-02e4d34a1d20"]
    
    init() {
        self.apiKey = "api-f5cfb140-5537-4c6f-806c-02e4d34a1d20"
        self.baseUrl = "https://app.launchdarkly.com/api/v2/"
    }
    
    func getData(path: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let url = baseUrl.appending(path)
        
        performRequest(url: url, headers: headers, completion: completionHandler)
    }
    
    func performRequest(url: String, headers: [String:String], completion: @escaping (Result<[String: Any]>) -> Void ) {
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            
            response in
            
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
