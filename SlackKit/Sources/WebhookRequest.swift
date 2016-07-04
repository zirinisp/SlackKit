//
//  WebhookRequest.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/3/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

internal struct WebhookRequest: Request {
    
    let token: String
    let teamID: String
    let teamDomain: String
    let channelID: String
    let channelName: String
    let userID: String
    let userName: String
    let command: String
    let text: String
    let responseURL: String
    
    internal init(request: [String: AnyObject]?) {
        token = request?["token"] as? String ?? ""
        teamID = request?["team_id"] as? String ?? ""
        teamDomain = request?["team_domain"] as? String ?? ""
        channelID = request?["channel_id"] as? String ?? ""
        channelName = request?["channel_name"] as? String ?? ""
        userID = request?["user_id"] as? String ?? ""
        userName = request?["user_name"] as? String ?? ""
        command = request?["command"] as? String ?? ""
        text = request?["text"] as? String ?? ""
        responseURL = request?["response_url"] as? String ?? ""
    }
    
}
