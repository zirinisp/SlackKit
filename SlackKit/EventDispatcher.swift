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

internal struct EventDispatcher {
    
    static func eventDispatcher(event: [String: AnyObject]) {
        let event = Event(event: event)
        if let type = event.type {
            switch type {
            case .Hello:
                EventHandler.connected()
            case .Ok:
                EventHandler.messageSent(event)
            case .Message:
                if (event.subtype != nil) {
                    messageDispatcher(event)
                } else {
                    EventHandler.messageReceived(event)
                }
            case .UserTyping:
                EventHandler.userTyping(event)
            case .ChannelMarked, .IMMarked, .GroupMarked:
                EventHandler.channelMarked(event)
            case .ChannelCreated, .IMCreated:
                EventHandler.channelCreated(event)
            case .ChannelJoined, .GroupJoined:
                EventHandler.channelJoined(event)
            case .ChannelLeft, .GroupLeft:
                EventHandler.channelLeft(event)
            case .ChannelDeleted:
                EventHandler.channelDeleted(event)
            case .ChannelRenamed, .GroupRename:
                EventHandler.channelRenamed(event)
            case .ChannelArchive, .GroupArchive:
                EventHandler.channelArchived(event, archived: true)
            case .ChannelUnarchive, .GroupUnarchive:
                EventHandler.channelArchived(event, archived: false)
            case .ChannelHistoryChanged, .IMHistoryChanged, .GroupHistoryChanged:
                EventHandler.channelHistoryChanged(event)
            case .DNDUpdated:
                EventHandler.doNotDisturbUpdated(event)
            case .DNDUpatedUser:
                EventHandler.doNotDisturbUserUpdated(event)
            case .IMOpen, .GroupOpen:
                EventHandler.open(event, open: true)
            case .IMClose, .GroupClose:
                EventHandler.open(event, open: false)
            case .FileCreated:
                EventHandler.processFile(event)
            case .FileShared:
                EventHandler.processFile(event)
            case .FileUnshared:
                EventHandler.processFile(event)
            case .FilePublic:
                EventHandler.processFile(event)
            case .FilePrivate:
                EventHandler.filePrivate(event)
            case .FileChanged:
                EventHandler.processFile(event)
            case .FileDeleted:
                EventHandler.deleteFile(event)
            case .FileCommentAdded:
                EventHandler.fileCommentAdded(event)
            case .FileCommentEdited:
                EventHandler.fileCommentEdited(event)
            case .FileCommentDeleted:
                EventHandler.fileCommentDeleted(event)
            case .PinAdded:
                EventHandler.pinAdded(event)
            case .PinRemoved:
                EventHandler.pinRemoved(event)
            case .PresenceChange:
                EventHandler.presenceChange(event)
            case .ManualPresenceChange:
                EventHandler.manualPresenceChange(event)
            case .PrefChange:
                EventHandler.changePreference(event)
            case .UserChange:
                EventHandler.userChange(event)
            case .TeamJoin:
                EventHandler.teamJoin(event)
            case .StarAdded:
                EventHandler.itemStarred(event, star: true)
            case .StarRemoved:
                EventHandler.itemStarred(event, star: false)
            case .ReactionAdded:
                EventHandler.addedReaction(event)
            case .ReactionRemoved:
                EventHandler.removedReaction(event)
            case .EmojiChanged:
                EventHandler.emojiChanged(event)
            case .CommandsChanged:
                // Not implemented per Slack documentation.
                break
            case .TeamPlanChange:
                EventHandler.teamPlanChange(event)
            case .TeamPrefChange:
                EventHandler.teamPreferenceChange(event)
            case .TeamRename:
                EventHandler.teamNameChange(event)
            case .TeamDomainChange:
                EventHandler.teamDomainChange(event)
            case .EmailDomainChange:
                EventHandler.emailDomainChange(event)
            case .BotAdded:
                EventHandler.bot(event)
            case .BotChanged:
                EventHandler.bot(event)
            case .AccountsChanged:
                // Not implemented per Slack documentation.
                break
            case .TeamMigrationStarted:
                Client.sharedInstance.connect()
            case .SubteamCreated, .SubteamUpdated:
                EventHandler.subteam(event)
            case .SubteamSelfAdded:
                EventHandler.subteamAddedSelf(event)
            case.SubteamSelfRemoved:
                EventHandler.subteamRemovedSelf(event)
            case .Error:
                print("Error: \(event)")
                break
            }
        }
    }
    
    static func messageDispatcher(event:Event) {
        let subtype = MessageSubtype(rawValue: event.subtype!)!
        switch subtype {
        case .MessageChanged:
            EventHandler.messageChanged(event)
        case .MessageDeleted:
            EventHandler.messageDeleted(event)
        default:
            EventHandler.messageReceived(event)
        }
    }
    
}
