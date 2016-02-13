//
// SlackWebAPI.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Starscream

internal enum SlackAPIEndpoint: String {
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


public class SlackWebAPI {

    public enum InfoType: String {
        case Purpose = "purpose"
        case Topic = "topic"
    }
    
    public enum ParseMode: String {
        case Full = "full"
        case None = "none"
    }
    
    public enum Presence: String {
        case Auto = "auto"
        case Away = "away"
    }
    
    private let client: Client
    
    required public init(client: Client) {
        self.client = client
    }
    
    //MARK: - Connection
    public func connect(success success: (connecting: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.RTMStart, token: client.token, parameters: nil, successClosure: {
                (response) -> Void in
                self.client.initialSetup(response)
                if let socketURL = response["url"] as? String {
                    let url = NSURL(string: socketURL)
                    self.client.webSocket = WebSocket(url: url!)
                    self.client.webSocket?.delegate = self.client
                    self.client.webSocket?.connect()
                }
            }){
                (error) -> Void in
                failure(error: error)
            }
    }
    
    //MARK: - Auth Test
    public func authenticationTest(completion: (authenticated: Bool)->Void) {
        client.api.request(.AuthTest, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                completion(authenticated: true)
            }) { (error) -> Void in
                completion(authenticated: false)
        }
    }
    
    //MARK: - Channels
    public func getHistoryForChannel(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, completion: (history: [String: AnyObject]?)->Void) {
        history(.ChannelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) {
            (history) -> Void in
            completion(history: history)
        }
    }
    
    public func getChannelInfo(id: String, completion: (channel: Channel?)->Void) {
        info(.ChannelsInfo, id: id) {(channel) -> Void in
            completion(channel: channel)
        }
    }
    
    public func getChannelsList(excludeArchived: Bool = false, completion: (channels: [[String: AnyObject]]?)->Void) {
        list(.ChannelsList) {(channels) -> Void in
            completion(channels: channels)
        }
    }
    
    public func markChannel(channel: String, timestamp: String, completion: (marked: Bool)->Void) {
        mark(.ChannelsMark, channel: channel, timestamp: timestamp){ (marked) -> Void in
            completion(marked: marked)
        }
    }
    
    public func setChannelPurpose(channel: String, purpose: String, completion: (success: Bool)->Void) {
        setInfo(.ChannelsSetPurpose, type: .Purpose, channel: channel, text: purpose) {(success) -> Void in
            completion(success: success)
        }
    }
    
    public func setChannelTopic(channel: String, topic: String, completion: (success: Bool)->Void) {
        setInfo(.ChannelsSetTopic, type: .Topic, channel: channel, text: topic) {(success) -> Void in
            completion(success: success)
        }
    }
    
    //MARK: - Messaging
    public func deleteMessage(channel: String, ts: String, completion: (deleted: Bool)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": ts]
        client.api.request(.ChatDelete, token: client.token, parameters: parameters, successClosure: { (response) -> Void in
                completion(deleted: true)
            }) {(error) -> Void in
                completion(deleted: true)
        }
    }
    
    public func sendMessage() {
        //TODO: Send message
    }
    
    public func updateMessage(channel: String, ts: String, message: String, attachments: [[String: AnyObject]]? = nil, parse:ParseMode = .None, linkNames: Bool = false, completion: (updated: Bool)->Void) {
        var parameters: [String: AnyObject] = ["channel": channel, "ts": ts, "text": message, "parse": parse.rawValue, "link_names": linkNames]
        if let attachments = attachments {
            parameters["attachments"] = attachments
        }
        client.api.request(.ChatUpdate, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(updated: true)
            }) {(error) -> Void in
                completion(updated: false)
        }
    }
    
    //MARK: - Emoji
    public func emojiList(completion: (emojiList: [String: AnyObject]?)->Void) {
        client.api.request(.EmojiList, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                completion(emojiList: response["emoji"] as? [String: AnyObject])
            }) { (error) -> Void in
                completion(emojiList: nil)
        }
    }
    
    //MARK: - Files
    public func deleteFile(fileID: String, completion: (deleted: Bool)->Void) {
        client.api.request(.FilesDelete, token: client.token, parameters: ["file":fileID], successClosure: {
            (response) -> Void in
                completion(deleted: true)
            }) {(error) -> Void in
                completion(deleted: false)
        }
    }
    
    public func uploadFile() {
        //TODO: Upload file
    }
    
    //MARK: - Groups
    public func closeGroup(groupID: String, completion: (closed: Bool)->Void) {
        close(.GroupsClose, channelID: groupID) {(closed) -> Void in
            completion(closed: closed)
        }
    }
    
    public func getHistoryForGroup(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, completion: (history: [String: AnyObject]?)->Void) {
        history(.GroupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) {(history) -> Void in
            completion(history: history)
        }
    }
    
    public func getGroupInfo(id: String, completion: (channel: Channel?)->Void) {
        info(.GroupsInfo, id: id) {(channel) -> Void in
            completion(channel: channel)
        }
    }
    
    public func getGroupsList(excludeArchived: Bool = false, completion: (channels: [[String: AnyObject]]?)->Void) {
        list(.GroupsList) {(channels) -> Void in
            completion(channels: channels)
        }
    }
    
    public func markGroup(channel: String, timestamp: String, completion: (marked: Bool)->Void) {
        mark(.GroupsMark, channel: channel, timestamp: timestamp){ (marked) -> Void in
            completion(marked: marked)
        }
    }
    
    public func openGroup(channel: String, completion: (opened: Bool)->Void) {
        client.api.request(.GroupsOpen, token: client.token, parameters: ["channel":channel], successClosure: {
            (response) -> Void in
                completion(opened: true)
            }) {(error) -> Void in
                completion(opened: false)
        }
    }
    
    public func setGroupPurpose(channel: String, purpose: String, completion: (success: Bool)->Void) {
        setInfo(.GroupsSetPurpose, type: .Purpose, channel: channel, text: purpose) {(success) -> Void in
            completion(success: success)
        }
    }
    
    public func setGroupTopic(channel: String, topic: String, completion: (success: Bool)->Void) {
        setInfo(.GroupsSetTopic, type: .Topic, channel: channel, text: topic) {(success) -> Void in
            completion(success: success)
        }
    }
    
    //MARK: - IM
    public func closeIM(channel: String, completion: (closed: Bool)->Void) {
        close(.IMClose, channelID: channel) {(closed) -> Void in
            completion(closed: closed)
        }
    }
    
    public func getHistoryForIM(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, completion: (history: [String: AnyObject]?)->Void) {
        history(.IMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) {(history) -> Void in
            completion(history: history)
        }
    }
    
    public func getIMList(excludeArchived: Bool = false, completion: (channels: [[String: AnyObject]]?)->Void) {
        list(.IMList) {(channels) -> Void in
            completion(channels: channels)
        }
    }
    
    public func markIM(channel: String, timestamp: String, completion: (marked: Bool)->Void) {
        mark(.IMMark, channel: channel, timestamp: timestamp){ (marked) -> Void in
            completion(marked: marked)
        }
    }
    
    public func openIM(userID: String, completion: (imID: String?)->Void) {
        client.api.request(.IMOpen, token: client.token, parameters: ["user":userID], successClosure: {
            (response) -> Void in
            if let channel = response["channel"] as? [String: AnyObject], id = channel["id"] as? String {
                let exists = self.client.channels.filter{$0.0 == id}.count > 0
                if exists == true {
                    self.client.channels[id]?.isOpen = true
                } else {
                    self.client.channels[id] = Channel(channel: channel)
                }
                completion(imID: id)
                
                if let delegate = self.client.groupEventsDelegate {
                    delegate.groupOpened(self.client.channels[id]!)
                }
            }

            }) {(error) -> Void in
        }
    }
    
    //MARK: - MPIM
    public func closeMPIM(channel: String, completion: (closed: Bool)->Void) {
        close(.MPIMClose, channelID: channel) {(closed) -> Void in
            completion(closed: closed)
        }
    }
    
    public func getHistoryForMPIM(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, completion: (history: [String: AnyObject]?)->Void) {
        history(.MPIMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads) {(history) -> Void in
            completion(history: history)
        }
    }
    
    public func getMPIMList(excludeArchived: Bool = false, completion: (channels: [[String: AnyObject]]?)->Void) {
        list(.MPIMList) {(channels) -> Void in
            completion(channels: channels)
        }
    }
    
    public func markMPIM(channel: String, timestamp: String, completion: (marked: Bool)->Void) {
        mark(.MPIMMark, channel: channel, timestamp: timestamp){ (marked) -> Void in
            completion(marked: marked)
        }
    }
    
    public func openMPIM(userIDs: [String], completion: (imID: String?)->Void) {
        let users = userIDs.joinWithSeparator(",")
        client.api.request(.MPIMOpen, token: client.token, parameters: ["users":users], successClosure: {
            (response) -> Void in
            if let channel = response["group"] as? [String: AnyObject], id = channel["id"] as? String {
                let exists = self.client.channels.filter{$0.0 == id}.count > 0
                if exists == true {
                    self.client.channels[id]?.isOpen = true
                } else {
                    self.client.channels[id] = Channel(channel: channel)
                }
                completion(imID: id)
            }
            }) {(error) -> Void in
                completion(imID: nil)
        }
    }
    
    //MARK: - Pins
    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, completion: (pinned: Bool)->Void) {
        var parameters: [String: AnyObject] = ["channel":channel]
        let optionalParameters = ["file":file, "file_comment":fileComment, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.PinsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(pinned: true)
            }){(error) -> Void in
                completion(pinned: false)
        }
    }
    
    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, completion: (unpinned: Bool)->Void) {
        var parameters: [String: AnyObject] = ["channel":channel]
        let optionalParameters = ["file":file, "file_comment":fileComment, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.PinsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(unpinned: true)
            }){(error) -> Void in
                completion(unpinned: false)
        }
    }
    
    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, completion: (reacted: Bool)->Void) {
        var parameters: [String: AnyObject] = ["name":name]
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.ReactionsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(reacted: true)
            }) {(error) -> Void in
                completion(reacted: false)
        }
    }
    
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, completion: (unreacted: Bool)->Void) {
        var parameters: [String: AnyObject] = ["name":name]
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.ReactionsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(unreacted: true)
            }) {(error) -> Void in
                completion(unreacted: false)
        }
    }
    
    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStar(file: String, fileComment: String, channel: String, timestamp: String, completion: (starred: Bool)->Void) {
        var parameters = [String: AnyObject]()
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.StarsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(starred: true)
            }) {(error) -> Void in
                completion(starred: false)
        }
    }
    
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStar(file: String, fileComment: String, channel: String, timestamp: String, completion: (unstarred: Bool)->Void) {
        var parameters = [String: AnyObject]()
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.StarsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(unstarred: true)
            }) {(error) -> Void in
                completion(unstarred: false)
        }
    }
    
    //MARK: - Team
    public func getTeamInfo(completion: (info: [String: AnyObject]?)->Void) {
        client.api.request(.TeamInfo, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                completion(info: response["team"] as? [String: AnyObject])
            }) {(error) -> Void in
                completion(info: nil)
        }
    }
    
    //MARK: - Users
    public func getUserPresence(user: String, completion: (presence: String?)->Void) {
        client.api.request(.UsersGetPresence, token: client.token, parameters: ["user":user], successClosure: {
            (response) -> Void in
                completion(presence: response["presence"] as? String)
            }){(error) -> Void in
                completion(presence: nil)
        }
    }
    
    public func getUserInfo(id: String, completion: (user: User?)->Void) {
        client.api.request(.UsersInfo, token: client.token, parameters: ["user":id], successClosure: {
            (response) -> Void in
                completion(user: User(user: response["user"] as? [String: AnyObject]))
            }) {(error) -> Void in
                completion(user: nil)
        }
    }
    
    public func getUserList(includePresence: Bool = false, completion: (userList: [[String: AnyObject]]?)->Void) {
        client.api.request(.UsersList, token: client.token, parameters: ["presence":includePresence], successClosure: {
            (response) -> Void in
                completion(userList: response["members"] as? [[String: AnyObject]])
            }){(error) -> Void in
                completion(userList: nil)
        }
    }
    
    public func setUserActive(completion: (success: Bool)->Void) {
        client.api.request(.UsersSetActive, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                completion(success: true)
            }) {(error) -> Void in
                completion(success: false)
        }
    }
    
    public func setUserPresence(presence: Presence, completion: (success: Bool)->Void) {
        client.api.request(.UsersSetPresence, token: client.token, parameters: ["presence":presence.rawValue], successClosure: {
            (response) -> Void in
                completion(success:true)
            }) {(error) -> Void in
                completion(success:false)
        }
    }
    
    //MARK: - Channel Utilities
    private func close(endpoint: SlackAPIEndpoint, channelID: String, completion: (closed: Bool)->Void) {
        client.api.request(endpoint, token: client.token, parameters: ["channel":channelID], successClosure: {
            (response) -> Void in
                completion(closed: true)
            }) {(error) -> Void in
                completion(closed: false)
        }
    }
    
    private func history(endpoint: SlackAPIEndpoint, id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, completion: (history: [String: AnyObject]?)->Void) {
        let parameters: [String: AnyObject] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(history: response)
            }) {(error) -> Void in
                completion(history: nil)
        }
    }
    
    private func info(endpoint: SlackAPIEndpoint, id: String, completion: (channel: Channel?)->Void) {
        client.api.request(endpoint, token: client.token, parameters: ["channel": id], successClosure: {
            (response) -> Void in
                completion(channel: Channel(channel: response["channel"] as? [String: AnyObject]))
            }) {(error) -> Void in
                completion(channel: nil)
        }
    }
    
    private func list(endpoint: SlackAPIEndpoint, excludeArchived: Bool = false, completion: (channels: [[String: AnyObject]]?)->Void) {
        let parameters: [String: AnyObject] = ["exclude_archived": excludeArchived]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(channels: response["channels"] as? [[String: AnyObject]])
            }) {(error) -> Void in
                completion(channels: nil)
        }
    }
    
    private func mark(endpoint: SlackAPIEndpoint, channel: String, timestamp: String, completion: (marked: Bool)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": timestamp]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(marked: true)
            }) {(error) -> Void in
                completion(marked: false)
        }
    }
    
    private func setInfo(endpoint: SlackAPIEndpoint, type: InfoType, channel: String, text: String, completion: (success: Bool)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, type.rawValue: text]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                completion(success: true)
            }) {(error) -> Void in
                completion(success: false)
        }
    }

}
