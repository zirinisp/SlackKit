//
//  NetworkInterface.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

public struct NetworkInterface {
    
    private static let apiUrl = "https://slack.com/api/"
    private static let token = Client.sharedInstance.token
    
    static public func slackAPIRequest(endpoint: String, parameters: [String: AnyObject]?, json: ([String: AnyObject]) -> Void) {
        var requestString = "\(apiUrl)\(endpoint)?token=\(token)"
        if let params = parameters {
            requestString = requestString + NetworkInterface.requestStringFromParameters(params)
        }
        let request = NSURLRequest(URL: NSURL(string: requestString)!)
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            guard let data = data else {
                return
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                if (result["ok"] as! Bool == true) {
                    json(result)
                } else {
                    //TODO: ERROR
                }
            } catch _ {
                print(error)
            }
        }
    }
    
    static private func requestStringFromParameters(parameters: [String: AnyObject]) -> String {
        var requestString = ""
        for key in parameters.keys {
            requestString = requestString + "&\(key)=\(parameters[key])"
        }
        
        return requestString
    }
}
