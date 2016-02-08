//
//  SlackWebAPI.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation
import Starscream

enum SlackAPIEndpoint: String {
    case APITest = "api.test"
    case AuthTest = "auth.test"
    case ChannelsHistory = "channels.history"
    case ChannelsInfo = "channels.info"
    case ChannelsList = "channels.list"
    case ChannelsMark = "channels.mark"
    case ChannelsSetPurpose = "channels.setPurpose"
    case ChannelsSetTopic = "channels.setTopic"
    case ChatDelete = "chat.delete"
    case ChatPostMessage = "chat.postMessage"
    case ChatUpdate = "chat.update"
    case EmojiList = "emoji.list"
    case FilesDelete = "files.delete"
    case FilesUpload = "files.upload"
    case GroupsClose = "groups.close"
    case GroupsHistory = "groups.history"
    case GroupsInfo = "groups.info"
    case GroupsList = "groups.list"
    case GroupsMark = "groups.mark"
    case GroupsOpen = "groups.open"
    case GroupsSetPurpose = "groups.setPurpose"
    case GroupsSetTopic = "groups.setTopic"
    case IMClose = "im.close"
    case IMHistory = "im.history"
    case IMList = "im.list"
    case IMMark = "im.mark"
    case IMOpen = "im.open"
    case MPIMClose = "mpim.close"
    case MPIMHistory = "mpim.history"
    case MPIMList = "mpim.list"
    case MPIMMark = "mpim.mark"
    case MPIMOpen = "mpim.open"
    case PinsAdd = "pins.add"
    case PinsRemove = "pins.remove"
    case ReactionsAdd = "reactions.add"
    case ReactionsGet = "reactions.get"
    case ReactionsList = "reactions.list"
    case ReactionsRemove = "reactions.remove"
    case RTMStart = "rtm.start"
    case StarsAdd = "stars.add"
    case StarsRemove = "stars.remove"
    case TeamInfo = "team.info"
    case UsersGetPresence = "users.getPresence"
    case UsersInfo = "users.info"
    case UsersList = "users.list"
    case UsersSetActive = "users.setActive"
    case UsersSetPresence = "users.setPresence"
}

public struct SlackWebAPI {

    //MARK: - Connection
    public static func connect() {
        Client.sharedInstance.api.request(SlackAPIEndpoint.RTMStart, parameters: nil) {
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
    public static func imOpen(userID: String, completion: (imID: String?) -> Void) {
        Client.sharedInstance.api.request(SlackAPIEndpoint.IMOpen, parameters: ["user":userID]) {
            (response) -> Void in
            if let channel = response["channel"] as? [String: AnyObject], id = channel["id"] as? String {
                let exists = Client.sharedInstance.channels.filter{$0.0 == id}.count > 0
                if exists == true {
                    Client.sharedInstance.channels[id]?.isOpen = true
                } else {
                    Client.sharedInstance.channels[id] = Channel(channel: channel)
                }
                completion(imID: id)
                
                if let delegate = Client.sharedInstance.groupEventsDelegate {
                    delegate.groupOpened(Client.sharedInstance.channels[id]!)
                }
            }
        }
    }
}
