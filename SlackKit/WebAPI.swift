//
//  WebAPI.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation
import Starscream

enum SlackWebAPI: String {
    case RTMStart = "rtm.start"
    case IMOpen = "im.open"
}

public struct WebAPI {

    //MARK: - Connection
    public static func connect() {
        NetworkInterface.slackAPIRequest(SlackWebAPI.RTMStart.rawValue, parameters: nil) {
            (response) -> Void in
            Client.sharedInstance.initialSetup(response)
            if let socketURL = response["url"] as? String {
                let url = NSURL(string: socketURL)
                Client.sharedInstance.webSocket = WebSocket(url: url!)
                Client.sharedInstance.webSocket?.delegate = Client.sharedInstance
                Client.sharedInstance.webSocket?.connect()
            }
        }
    }
    
    //MARK: - IM
    public static func imOpen(userID: String, callback: (String?) -> Void) {
        NetworkInterface.slackAPIRequest(SlackWebAPI.IMOpen.rawValue, parameters: ["user":userID]) {
            (response) -> Void in
            if let channel = response["channel"] as? [String: AnyObject], id = channel["id"] as? String {
                let exists = Client.sharedInstance.channels.filter{$0.0 == id}.count > 0
                if exists == true {
                    Client.sharedInstance.channels[id]?.isOpen = true
                } else {
                    Client.sharedInstance.channels[id] = Channel(channel: channel)
                }
                
                if let delegate = Client.sharedInstance.groupEventsDelegate {
                    delegate.groupOpened(Client.sharedInstance.channels[id]!)
                }
            }
        }
    }
}
