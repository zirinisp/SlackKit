//
// EventDispatcher.swift
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

internal class EventDispatcher {
    let client: SlackClient
    let handler: EventHandler
    
    required init(client: SlackClient) {
        self.client = client
        handler = EventHandler(client: client)
    }
    
    func dispatch(event: [String: AnyObject]) {
        let event = Event(event: event)
        if let type = event.type {
            switch type {
            case .Hello:
                handler.connected()
            case .Ok:
                handler.messageSent(event: event)
            case .Message:
                if (event.subtype != nil) {
                    messageDispatcher(event: event)
                } else {
                    handler.messageReceived(event: event)
                }
            case .UserTyping:
                handler.userTyping(event: event)
            case .ChannelMarked, .IMMarked, .GroupMarked:
                handler.channelMarked(event: event)
            case .ChannelCreated, .IMCreated:
                handler.channelCreated(event: event)
            case .ChannelJoined, .GroupJoined:
                handler.channelJoined(event: event)
            case .ChannelLeft, .GroupLeft:
                handler.channelLeft(event: event)
            case .ChannelDeleted:
                handler.channelDeleted(event: event)
            case .ChannelRenamed, .GroupRename:
                handler.channelRenamed(event: event)
            case .ChannelArchive, .GroupArchive:
                handler.channelArchived(event: event, archived: true)
            case .ChannelUnarchive, .GroupUnarchive:
                handler.channelArchived(event: event, archived: false)
            case .ChannelHistoryChanged, .IMHistoryChanged, .GroupHistoryChanged:
                handler.channelHistoryChanged(event: event)
            case .DNDUpdated:
                handler.doNotDisturbUpdated(event: event)
            case .DNDUpatedUser:
                handler.doNotDisturbUserUpdated(event: event)
            case .IMOpen, .GroupOpen:
                handler.open(event: event, open: true)
            case .IMClose, .GroupClose:
                handler.open(event: event, open: false)
            case .FileCreated:
                handler.processFile(event: event)
            case .FileShared:
                handler.processFile(event: event)
            case .FileUnshared:
                handler.processFile(event: event)
            case .FilePublic:
                handler.processFile(event: event)
            case .FilePrivate:
                handler.filePrivate(event: event)
            case .FileChanged:
                handler.processFile(event: event)
            case .FileDeleted:
                handler.deleteFile(event: event)
            case .FileCommentAdded:
                handler.fileCommentAdded(event: event)
            case .FileCommentEdited:
                handler.fileCommentEdited(event: event)
            case .FileCommentDeleted:
                handler.fileCommentDeleted(event: event)
            case .PinAdded:
                handler.pinAdded(event: event)
            case .PinRemoved:
                handler.pinRemoved(event: event)
            case .Pong:
                handler.pong(event: event)
            case .PresenceChange:
                handler.presenceChange(event: event)
            case .ManualPresenceChange:
                handler.manualPresenceChange(event: event)
            case .PrefChange:
                handler.changePreference(event: event)
            case .UserChange:
                handler.userChange(event: event)
            case .TeamJoin:
                handler.teamJoin(event: event)
            case .StarAdded:
                handler.itemStarred(event: event, star: true)
            case .StarRemoved:
                handler.itemStarred(event: event, star: false)
            case .ReactionAdded:
                handler.addedReaction(event: event)
            case .ReactionRemoved:
                handler.removedReaction(event: event)
            case .EmojiChanged:
                handler.emojiChanged(event: event)
            case .CommandsChanged:
                // This functionality is only used by our web client. 
                // The other APIs required to support slash command metadata are currently unstable. 
                // Until they are released other clients should ignore this event.
                break
            case .TeamPlanChange:
                handler.teamPlanChange(event: event)
            case .TeamPrefChange:
                handler.teamPreferenceChange(event: event)
            case .TeamRename:
                handler.teamNameChange(event: event)
            case .TeamDomainChange:
                handler.teamDomainChange(event: event)
            case .EmailDomainChange:
                handler.emailDomainChange(event: event)
            case .TeamProfileChange:
                handler.teamProfileChange(event: event)
            case .TeamProfileDelete:
                handler.teamProfileDeleted(event: event)
            case .TeamProfileReorder:
                handler.teamProfileReordered(event: event)
            case .BotAdded:
                handler.bot(event: event)
            case .BotChanged:
                handler.bot(event: event)
            case .AccountsChanged:
                // The accounts_changed event is used by our web client to maintain a list of logged-in accounts.
                // Other clients should ignore this event.
                break
            case .TeamMigrationStarted:
                client.connect(pingInterval: client.pingInterval, timeout: client.timeout, reconnect: client.reconnect)
            case .ReconnectURL:
                // The reconnect_url event is currently unsupported and experimental.
                break
            case .SubteamCreated, .SubteamUpdated:
                handler.subteam(event: event)
            case .SubteamSelfAdded:
                handler.subteamAddedSelf(event: event)
            case.SubteamSelfRemoved:
                handler.subteamRemovedSelf(event: event)
            case .Error:
                print("Error: \(event)")
                break
            }
        }
    }
    
    func messageDispatcher(event:Event) {
        let subtype = MessageSubtype(rawValue: event.subtype!)!
        switch subtype {
        case .MessageChanged:
            handler.messageChanged(event: event)
        case .MessageDeleted:
            handler.messageDeleted(event: event)
        default:
            handler.messageReceived(event: event)
        }
    }
    
}
