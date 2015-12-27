//
// EventDispatcher.swift
//
// Copyright © 2015 Peter Zignego. All rights reserved.
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
        switch event.type {
        case .Hello:
            EventHandler.connected()
            break
        case .Ok:
            EventHandler.messageSent(event)
            break
        case .Message:
            if (event.subtype != nil) {
                messageDispatcher(event)
            } else {
                EventHandler.messageReceived(event)
            }
            break
        case .UserTyping:
            EventHandler.userTyping(event)
            break
        case .ChannelMarked, .IMMarked, .GroupMarked:
            EventHandler.channelMarked(event)
            break
        case .ChannelCreated, .IMCreated:
            EventHandler.channelCreated(event)
            break
        case .ChannelJoined, .GroupJoined:
            EventHandler.channelJoined(event)
            break
        case .ChannelLeft, .GroupLeft:
            EventHandler.channelLeft(event)
            break
        case .ChannelDeleted:
            EventHandler.channelDeleted(event)
            break
        case .ChannelRenamed, .GroupRename:
            EventHandler.channelRenamed(event)
            break
        case .ChannelArchive, .GroupArchive:
            EventHandler.channelArchived(event, archived: true)
            break
        case .ChannelUnarchive, .GroupUnarchive:
            EventHandler.channelArchived(event, archived: false)
            break
        case .ChannelHistoryChanged, .IMHistoryChanged, .GroupHistoryChanged:
            EventHandler.channelHistoryChanged(event)
            break
        case .IMOpen, .GroupOpen:
            EventHandler.open(event, open: true)
            break
        case .IMClose, .GroupClose:
            EventHandler.open(event, open: false)
            break
        case .FileCreated:
            EventHandler.processFile(event)
            break
        case .FileShared:
            EventHandler.processFile(event)
            break
        case .FileUnshared:
            EventHandler.processFile(event)
            break
        case .FilePublic:
            EventHandler.processFile(event)
            break
        case .FilePrivate:
            EventHandler.filePrivate(event)
            break
        case .FileChanged:
            EventHandler.processFile(event)
            break
        case .FileDeleted:
            EventHandler.deleteFile(event)
            break
        case .FileCommentAdded:
            EventHandler.fileCommentAdded(event)
            break
        case .FileCommentEdited:
            EventHandler.fileCommentEdited(event)
            break
        case .FileCommentDeleted:
            EventHandler.fileCommentDeleted(event)
            break
        case .PinAdded:
            EventHandler.pinAdded(event)
            break
        case .PinRemoved:
            EventHandler.pinRemoved(event)
            break
        case .PresenceChange:
            EventHandler.presenceChange(event)
            break
        case .ManualPresenceChange:
            EventHandler.manualPresenceChange(event)
            break
        case .PrefChange:
            EventHandler.changePreference(event)
            break
        case .UserChange:
            EventHandler.userChange(event)
            break
        case .TeamJoin:
            EventHandler.teamJoin(event)
            break
        case .StarAdded:
            EventHandler.messageStarred(event, star: true)
            break
        case .StarRemoved:
            EventHandler.messageStarred(event, star: false)
            break
        case .ReactionAdded:
            EventHandler.addedReaction(event)
            break
        case .ReactionRemoved:
            EventHandler.removedReaction(event)
            break
        case .EmojiChanged:
            EventHandler.emojiChanged(event)
            break
        case .CommandsChanged:
            // Not implemented per Slack documentation.
            break
        case .TeamPlanChange:
            EventHandler.teamPlanChange(event)
            break
        case .TeamPrefChange:
            EventHandler.teamPreferenceChange(event)
            break
        case .TeamRename:
            EventHandler.teamNameChange(event)
            break
        case .TeamDomainChange:
            EventHandler.teamDomainChange(event)
            break
        case .EmailDomainChange:
            EventHandler.emailDomainChange(event)
            break
        case .BotAdded:
            EventHandler.bot(event)
            break
        case .BotChanged:
            EventHandler.bot(event)
            break
        case .AccountsChanged:
            // Not implemented per Slack documentation.
            break
        case .TeamMigrationStarted:
            Client.sharedInstance.connect()
            break
        case .SubteamCreated, .SubteamUpdated:
            EventHandler.subteam(event)
            break
        case .SubteamSelfAdded:
            EventHandler.subteamAddedSelf(event)
            break
        case.SubteamSelfRemoved:
            EventHandler.subteamRemovedSelf(event)
            break
        case .Error:
            
            break
        }
    }
    
    static func messageDispatcher(event:Event) {
        let subtype = MessageSubtype(rawValue: event.subtype!)!
        switch subtype {
        case .MessageChanged:
            EventHandler.messageChanged(event)
            break
        case .MessageDeleted:
            EventHandler.messageDeleted(event)
            break
        default:
            EventHandler.messageReceived(event)
            break
        }
    }
    
}
