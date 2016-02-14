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
    public func connect(success success: (response: [String: AnyObject])->Void, failure: (error: SlackError)->Void) {
        client.api.request(.RTMStart, token: client.token, parameters: nil, successClosure: {
                (response) -> Void in
                success(response: response)
            }) {(error) -> Void in
                failure(error: error)
            }
    }
    
    //MARK: - Auth Test
    public func authenticationTest(success: (authenticated: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.AuthTest, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success(authenticated: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Channels
    public func getHistoryForChannel(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: (history: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        history(.ChannelsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success(history:history)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getChannelInfo(id: String, success: (channel: Channel?)->Void, failure: (error: SlackError)->Void) {
        info(.ChannelsInfo, id: id, success: {
            (channel) -> Void in
                success(channel: channel)
            }) { (error) -> Void in
                failure(error: error)
        }
    }
    
    public func getChannelsList(excludeArchived: Bool = false, success: (channels: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        list(.ChannelsList, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success(channels: channels)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func markChannel(channel: String, timestamp: String, success: (marked: Bool)->Void, failure: (error: SlackError)->Void) {
        mark(.ChannelsMark, channel: channel, timestamp: timestamp, success: {
            (marked) -> Void in
                success(marked:marked)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func setChannelPurpose(channel: String, purpose: String, success: (purposeSet: Bool)->Void, failure: (error: SlackError)->Void) {
        setInfo(.ChannelsSetPurpose, type: .Purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success(purposeSet: purposeSet)
            }) { (error) -> Void in
                failure(error: error)
        }
    }
    
    public func setChannelTopic(channel: String, topic: String, success: (topicSet: Bool)->Void, failure: (error: SlackError)->Void) {
        setInfo(.ChannelsSetTopic, type: .Topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success(topicSet: topicSet)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Messaging
    public func deleteMessage(channel: String, ts: String, success: (deleted: Bool)->Void, failure: (error: SlackError)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": ts]
        client.api.request(.ChatDelete, token: client.token, parameters: parameters, successClosure: { (response) -> Void in
                success(deleted: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func sendMessage() {
        //TODO: Send message
    }
    
    public func updateMessage(channel: String, ts: String, message: String, attachments: [[String: AnyObject]]? = nil, parse:ParseMode = .None, linkNames: Bool = false, success: (updated: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters: [String: AnyObject] = ["channel": channel, "ts": ts, "text": message, "parse": parse.rawValue, "link_names": linkNames]
        if let attachments = attachments {
            parameters["attachments"] = attachments
        }
        client.api.request(.ChatUpdate, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(updated: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Emoji
    public func emojiList(success: (emojiList: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.EmojiList, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success(emojiList: response["emoji"] as? [String: AnyObject])
            }) { (error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Files
    public func deleteFile(fileID: String, success: (deleted: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.FilesDelete, token: client.token, parameters: ["file":fileID], successClosure: {
            (response) -> Void in
                success(deleted: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func uploadFile() {
        //TODO: Upload file
    }
    
    //MARK: - Groups
    public func closeGroup(groupID: String, success: (closed: Bool)->Void, failure: (error: SlackError)->Void) {
        close(.GroupsClose, channelID: groupID, success: {
            (closed) -> Void in
                success(closed:closed)
            }) {(error) -> Void in
                failure(error:error)
        }
    }
    
    public func getHistoryForGroup(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: (history: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        history(.GroupsHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success(history: history)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getGroupInfo(id: String, success: (channel: Channel?)->Void, failure: (error: SlackError)->Void) {
        info(.GroupsInfo, id: id, success: {
            (channel) -> Void in
                success(channel: channel)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getGroupsList(excludeArchived: Bool = false, success: (channels: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        list(.GroupsList, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success(channels: channels)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func markGroup(channel: String, timestamp: String, success: (marked: Bool)->Void, failure: (error: SlackError)->Void) {
        mark(.GroupsMark, channel: channel, timestamp: timestamp, success: {
            (marked) -> Void in
                success(marked: marked)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func openGroup(channel: String, success: (opened: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.GroupsOpen, token: client.token, parameters: ["channel":channel], successClosure: {
            (response) -> Void in
                success(opened: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func setGroupPurpose(channel: String, purpose: String, success: (purposeSet: Bool)->Void, failure: (error: SlackError)->Void) {
        setInfo(.GroupsSetPurpose, type: .Purpose, channel: channel, text: purpose, success: {
            (purposeSet) -> Void in
                success(purposeSet: purposeSet)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func setGroupTopic(channel: String, topic: String, success: (topicSet: Bool)->Void, failure: (error: SlackError)->Void) {
        setInfo(.GroupsSetTopic, type: .Topic, channel: channel, text: topic, success: {
            (topicSet) -> Void in
                success(topicSet: topicSet)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - IM
    public func closeIM(channel: String, success: (closed: Bool)->Void, failure: (error: SlackError)->Void) {
        close(.IMClose, channelID: channel, success: {
            (closed) -> Void in
                success(closed: closed)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getHistoryForIM(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: (history: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        history(.IMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success(history: history)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getIMList(excludeArchived: Bool = false, success: (channels: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        list(.IMList, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success(channels: channels)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func markIM(channel: String, timestamp: String, success: (marked: Bool)->Void, failure: (error: SlackError)->Void) {
        mark(.IMMark, channel: channel, timestamp: timestamp, success: {
            (marked) -> Void in
                success(marked: marked)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func openIM(userID: String, success: (imID: String?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.IMOpen, token: client.token, parameters: ["user":userID], successClosure: {
            (response) -> Void in
            if let channel = response["channel"] as? [String: AnyObject], id = channel["id"] as? String {
                let exists = self.client.channels.filter{$0.0 == id}.count > 0
                if exists == true {
                    self.client.channels[id]?.isOpen = true
                } else {
                    self.client.channels[id] = Channel(channel: channel)
                }
                success(imID: id)
                
                if let delegate = self.client.groupEventsDelegate {
                    delegate.groupOpened(self.client.channels[id]!)
                }
            }

            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - MPIM
    public func closeMPIM(channel: String, success: (closed: Bool)->Void, failure: (error: SlackError)->Void) {
        close(.MPIMClose, channelID: channel, success: {
            (closed) -> Void in
                success(closed: closed)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getHistoryForMPIM(id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: (history: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        history(.MPIMHistory, id: id, latest: latest, oldest: oldest, inclusive: inclusive, count: count, unreads: unreads, success: {
            (history) -> Void in
                success(history: history)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getMPIMList(excludeArchived: Bool = false, success: (channels: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        list(.MPIMList, excludeArchived: excludeArchived, success: {
            (channels) -> Void in
                success(channels: channels)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func markMPIM(channel: String, timestamp: String, success: (marked: Bool)->Void, failure: (error: SlackError)->Void) {
        mark(.MPIMMark, channel: channel, timestamp: timestamp, success: {
            (marked) -> Void in
                success(marked: marked)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func openMPIM(userIDs: [String], success: (imID: String?)->Void, failure: (error: SlackError)->Void) {
        let users = userIDs.joinWithSeparator(",")
        client.api.request(.MPIMOpen, token: client.token, parameters: ["users":users], successClosure: {
            (response) -> Void in
                let group = response["group"] as? [String: AnyObject]
                success(imID: group?["id"] as? String)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Pins
    public func pinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: (pinned: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters: [String: AnyObject] = ["channel":channel]
        let optionalParameters = ["file":file, "file_comment":fileComment, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.PinsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(pinned: true)
            }){(error) -> Void in
                failure(error: error)
        }
    }
    
    public func unpinItem(channel: String, file: String? = nil, fileComment: String? = nil, timestamp: String? = nil, success: (unpinned: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters: [String: AnyObject] = ["channel":channel]
        let optionalParameters = ["file":file, "file_comment":fileComment, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.PinsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(unpinned: true)
            }){(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Reactions
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func addReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: (reacted: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters: [String: AnyObject] = ["name":name]
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.ReactionsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(reacted: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    // One of file, file_comment, or the combination of channel and timestamp must be specified.
    public func removeReaction(name: String, file: String? = nil, fileComment: String? = nil, channel: String? = nil, timestamp: String? = nil, success: (unreacted: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters: [String: AnyObject] = ["name":name]
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.ReactionsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(unreacted: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Stars
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func addStar(file: String, fileComment: String, channel: String, timestamp: String, success: (starred: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters = [String: AnyObject]()
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.StarsAdd, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(starred: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    // One of file, file_comment, channel, or the combination of channel and timestamp must be specified.
    public func removeStar(file: String, fileComment: String, channel: String, timestamp: String, success: (unstarred: Bool)->Void, failure: (error: SlackError)->Void) {
        var parameters = [String: AnyObject]()
        let optionalParameters = ["file":file, "file_comment":fileComment, "channel":channel, "timestamp":timestamp]
        for key in optionalParameters.keys {
            if optionalParameters[key] != nil {
                parameters[key] = optionalParameters[key]!
            }
        }
        client.api.request(.StarsRemove, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(unstarred: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Team
    public func getTeamInfo(success: (info: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.TeamInfo, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success(info: response["team"] as? [String: AnyObject])
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Users
    public func getUserPresence(user: String, success: (presence: String?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.UsersGetPresence, token: client.token, parameters: ["user":user], successClosure: {
            (response) -> Void in
                success(presence: response["presence"] as? String)
            }){(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getUserInfo(id: String, success: (user: User?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.UsersInfo, token: client.token, parameters: ["user":id], successClosure: {
            (response) -> Void in
                success(user: User(user: response["user"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func getUserList(includePresence: Bool = false, success: (userList: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.UsersList, token: client.token, parameters: ["presence":includePresence], successClosure: {
            (response) -> Void in
                success(userList: response["members"] as? [[String: AnyObject]])
            }){(error) -> Void in
                failure(error: error)
        }
    }
    
    public func setUserActive(success: (success: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.UsersSetActive, token: client.token, parameters: nil, successClosure: {
            (response) -> Void in
                success(success: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    public func setUserPresence(presence: Presence, success: (success: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(.UsersSetPresence, token: client.token, parameters: ["presence":presence.rawValue], successClosure: {
            (response) -> Void in
                success(success:true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    //MARK: - Channel Utilities
    private func close(endpoint: SlackAPIEndpoint, channelID: String, success: (closed: Bool)->Void, failure: (error: SlackError)->Void) {
        client.api.request(endpoint, token: client.token, parameters: ["channel":channelID], successClosure: {
            (response) -> Void in
                success(closed: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    private func history(endpoint: SlackAPIEndpoint, id: String, latest: String = "\(NSDate().timeIntervalSince1970)", oldest: String = "0", inclusive: Bool = false, count: Int = 100, unreads: Bool = false, success: (history: [String: AnyObject]?)->Void, failure: (error: SlackError)->Void) {
        let parameters: [String: AnyObject] = ["channel": id, "latest": latest, "oldest": oldest, "inclusive":inclusive, "count":count, "unreads":unreads]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(history: response)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    private func info(endpoint: SlackAPIEndpoint, id: String, success: (channel: Channel?)->Void, failure: (error: SlackError)->Void) {
        client.api.request(endpoint, token: client.token, parameters: ["channel": id], successClosure: {
            (response) -> Void in
                success(channel: Channel(channel: response["channel"] as? [String: AnyObject]))
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    private func list(endpoint: SlackAPIEndpoint, excludeArchived: Bool = false, success: (channels: [[String: AnyObject]]?)->Void, failure: (error: SlackError)->Void) {
        let parameters: [String: AnyObject] = ["exclude_archived": excludeArchived]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(channels: response["channels"] as? [[String: AnyObject]])
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    private func mark(endpoint: SlackAPIEndpoint, channel: String, timestamp: String, success: (marked: Bool)->Void, failure: (error: SlackError)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, "ts": timestamp]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(marked: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }
    
    private func setInfo(endpoint: SlackAPIEndpoint, type: InfoType, channel: String, text: String, success: (success: Bool)->Void, failure: (error: SlackError)->Void) {
        let parameters: [String: AnyObject] = ["channel": channel, type.rawValue: text]
        client.api.request(endpoint, token: client.token, parameters: parameters, successClosure: {
            (response) -> Void in
                success(success: true)
            }) {(error) -> Void in
                failure(error: error)
        }
    }

}
