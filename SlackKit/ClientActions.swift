//
//  ClientActions.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

extension Client {
    
    //MARK: - User & Channel
    public func getChannelOrUserIdByName(name: String) -> String? {
        if (name[name.startIndex] == "@") {
            return getUserIdByName(name)
        } else if (name[name.startIndex] == "C") {
            return getChannelIDByName(name)
        }
        return nil
    }
    
    public func getChannelIDByName(name: String) -> String? {
        return channels.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getUserIdByName(name: String) -> String? {
        return users.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getImIDForUserWithID(id: String, callback: (String?) -> Void) {
        let ims = Client.sharedInstance.channels.filter{$0.1.isIM == true}
        let channel = ims.filter{$0.1.user == id}.first
        if let channel = channel, user = channel.1.user {
            callback(user)
        } else {
            WebAPI.imOpen(id, callback: callback)
        }
    }
    
    //MARK: - Utilities
    internal func stripString(var string: String) -> String {
        if string[string.startIndex] == "@" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        } else if string[string.startIndex] == "#" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        }
        return string
    }
    
}