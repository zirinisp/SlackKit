//
// Client+EventDispatching.swift
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

internal extension SlackClient {
    
    func dispatch(event: [String: Any]) {
        let event = Event(event: event)
        if let type = event.type {
            switch type {
            case .Hello:
                connected = true
                slackEventsDelegate?.clientConnected()
            case .Ok:
                messageSent(event: event)
            case .Message:
                if (event.subtype != nil) {
                    messageDispatcher(event: event)
                } else {
                    messageReceived(event: event)
                }
            case .UserTyping:
                userTyping(event: event)
            case .ChannelMarked, .IMMarked, .GroupMarked:
                channelMarked(event: event)
            case .ChannelCreated, .IMCreated:
                channelCreated(event: event)
            case .ChannelJoined, .GroupJoined:
                channelJoined(event: event)
            case .ChannelLeft, .GroupLeft:
                channelLeft(event: event)
            case .ChannelDeleted:
                channelDeleted(event: event)
            case .ChannelRenamed, .GroupRename:
                channelRenamed(event: event)
            case .ChannelArchive, .GroupArchive:
                channelArchived(event: event, archived: true)
            case .ChannelUnarchive, .GroupUnarchive:
                channelArchived(event: event, archived: false)
            case .ChannelHistoryChanged, .IMHistoryChanged, .GroupHistoryChanged:
                channelHistoryChanged(event: event)
            case .DNDUpdated:
                doNotDisturbUpdated(event: event)
            case .DNDUpatedUser:
                doNotDisturbUserUpdated(event: event)
            case .IMOpen, .GroupOpen:
                open(event: event, open: true)
            case .IMClose, .GroupClose:
                open(event: event, open: false)
            case .FileCreated:
                processFile(event: event)
            case .FileShared:
                processFile(event: event)
            case .FileUnshared:
                processFile(event: event)
            case .FilePublic:
                processFile(event: event)
            case .FilePrivate:
                filePrivate(event: event)
            case .FileChanged:
                processFile(event: event)
            case .FileDeleted:
                deleteFile(event: event)
            case .FileCommentAdded:
                fileCommentAdded(event: event)
            case .FileCommentEdited:
                fileCommentEdited(event: event)
            case .FileCommentDeleted:
                fileCommentDeleted(event: event)
            case .PinAdded:
                pinAdded(event: event)
            case .PinRemoved:
                pinRemoved(event: event)
            case .Pong:
                pong(event: event)
            case .PresenceChange:
                presenceChange(event: event)
            case .ManualPresenceChange:
                manualPresenceChange(event: event)
            case .PrefChange:
                changePreference(event: event)
            case .UserChange:
                userChange(event: event)
            case .TeamJoin:
                teamJoin(event: event)
            case .StarAdded:
                itemStarred(event: event, star: true)
            case .StarRemoved:
                itemStarred(event: event, star: false)
            case .ReactionAdded:
                addedReaction(event: event)
            case .ReactionRemoved:
                removedReaction(event: event)
            case .EmojiChanged:
                emojiChanged(event: event)
            case .CommandsChanged:
                // This functionality is only used by our web client. 
                // The other APIs required to support slash command metadata are currently unstable. 
                // Until they are released other clients should ignore this event.
                break
            case .TeamPlanChange:
                teamPlanChange(event: event)
            case .TeamPrefChange:
                teamPreferenceChange(event: event)
            case .TeamRename:
                teamNameChange(event: event)
            case .TeamDomainChange:
                teamDomainChange(event: event)
            case .EmailDomainChange:
                emailDomainChange(event: event)
            case .TeamProfileChange:
                teamProfileChange(event: event)
            case .TeamProfileDelete:
                teamProfileDeleted(event: event)
            case .TeamProfileReorder:
                teamProfileReordered(event: event)
            case .BotAdded:
                bot(event: event)
            case .BotChanged:
                bot(event: event)
            case .AccountsChanged:
                // The accounts_changed event is used by our web client to maintain a list of logged-in accounts.
                // Other clients should ignore this event.
                break
            case .TeamMigrationStarted:
                connect(pingInterval: pingInterval, timeout: timeout, reconnect: reconnect)
            case .ReconnectURL:
                // The reconnect_url event is currently unsupported and experimental.
                break
            case .SubteamCreated, .SubteamUpdated:
                subteam(event: event)
            case .SubteamSelfAdded:
                subteamAddedSelf(event: event)
            case.SubteamSelfRemoved:
                subteamRemovedSelf(event: event)
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
            messageChanged(event: event)
        case .MessageDeleted:
            messageDeleted(event: event)
        default:
            messageReceived(event: event)
        }
    }
    
}
