//
// EventHandler.swift
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

internal class EventHandler {
    let client: SlackClient
    required init(client: SlackClient) {
        self.client = client
    }
    
    //MARK: - Initial connection
    func connected() {
        client.connected = true
        
        if let delegate = client.slackEventsDelegate {
            delegate.clientConnected()
        }
    }
    
    //MARK: - Pong
    func pong(event: Event) {
        client.pong = event.replyTo
    }
    
    //MARK: - Messages
    func messageSent(event: Event) {
        if let reply = event.replyTo, message = client.sentMessages[NSNumber(value: reply).stringValue], channel = message.channel, ts = message.ts {
            message.ts = event.ts
            message.text = event.text
            client.channels[channel]?.messages[ts] = message
            
            if let delegate = client.messageEventsDelegate {
                delegate.messageSent(message: message)
            }
        }
    }
    
    func messageReceived(event: Event) {
        if let channel = event.channel, message = event.message, id = channel.id, ts = message.ts {
            client.channels[id]?.messages[ts] = message
            
            if let delegate = client.messageEventsDelegate {
                delegate.messageReceived(message: message)
            }
        }
    }
    
    func messageChanged(event: Event) {
        if let id = event.channel?.id, nested = event.nestedMessage, ts = nested.ts {
            client.channels[id]?.messages[ts] = nested
            
            if let delegate = client.messageEventsDelegate {
                delegate.messageChanged(message: nested)
            }
        }
    }
    
    func messageDeleted(event: Event) {
        if let id = event.channel?.id, key = event.message?.deletedTs {
            let message = client.channels[id]?.messages[key]
            client.channels[id]?.messages.removeValue(forKey:key)
            
            if let delegate = client.messageEventsDelegate {
                delegate.messageDeleted(message: message)
            }
        }
    }
    
    //MARK: - Channels
    func userTyping(event: Event) {
        if let channelID = event.channel?.id, userID = event.user?.id {
            if let _ = client.channels[channelID] {
                if (!client.channels[channelID]!.usersTyping.contains(userID)) {
                    client.channels[channelID]?.usersTyping.append(userID)
                    
                    if let delegate = client.channelEventsDelegate {
                        delegate.userTyping(channel: event.channel, user: event.user)
                    }
                }
            }
            
            let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
            dispatch_after(timeout, dispatch_get_main_queue()) {
                if let index = self.client.channels[channelID]?.usersTyping.index(of:userID) {
                    self.client.channels[channelID]?.usersTyping.remove(at: index)
                }
            }
        }
    }
    
    func channelMarked(event: Event) {
        if let channel = event.channel, id = channel.id {
            client.channels[id]?.lastRead = event.ts
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelMarked(channel: channel, timestamp: event.ts)
            }
        }
        //TODO: Recalculate unreads
    }
    
    func channelCreated(event: Event) {
        if let channel = event.channel, id = channel.id {
            client.channels[id] = channel
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelCreated(channel: channel)
            }
        }
    }
    
    func channelDeleted(event: Event) {
        if let channel = event.channel, id = channel.id {
            client.channels.removeValue(forKey:id)
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelDeleted(channel: channel)
            }
        }
    }
    
    func channelJoined(event: Event) {
        if let channel = event.channel, id = channel.id {
            client.channels[id] = event.channel
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelJoined(channel: channel)
            }
        }
    }
    
    func channelLeft(event: Event) {
        if let channel = event.channel, id = channel.id, userID = client.authenticatedUser?.id {
            if let index = client.channels[id]?.members?.index(of:userID) {
                client.channels[id]?.members?.remove(at: index)
                
                if let delegate = client.channelEventsDelegate {
                    delegate.channelLeft(channel: channel)
                }
            }
        }
    }
    
    func channelRenamed(event: Event) {
        if let channel = event.channel, id = channel.id {
            client.channels[id]?.name = channel.name
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelRenamed(channel: channel)
            }
        }
    }
    
    func channelArchived(event: Event, archived: Bool) {
        if let channel = event.channel, id = channel.id {
            client.channels[id]?.isArchived = archived
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelArchived(channel: channel)
            }
        }
    }
    
    func channelHistoryChanged(event: Event) {
        if let channel = event.channel {
            //TODO: Reload chat history if there are any cached messages before latest
            
            if let delegate = client.channelEventsDelegate {
                delegate.channelHistoryChanged(channel: channel)
            }
        }
    }
    
    //MARK: - Do Not Disturb
    func doNotDisturbUpdated(event: Event) {
        if let dndStatus = event.dndStatus {
            client.authenticatedUser?.doNotDisturbStatus = dndStatus
            
            if let delegate = client.doNotDisturbEventsDelegate {
                delegate.doNotDisturbUpdated(dndStatus: dndStatus)
            }
        }
    }
    
    func doNotDisturbUserUpdated(event: Event) {
        if let dndStatus = event.dndStatus, user = event.user, id = user.id {
            client.users[id]?.doNotDisturbStatus = dndStatus
            
            if let delegate = client.doNotDisturbEventsDelegate {
                delegate.doNotDisturbUserUpdated(dndStatus: dndStatus, user: user)
            }
        }
    }
    
    //MARK: - IM & Group Open/Close
    func open(event: Event, open: Bool) {
        if let channel = event.channel, id = channel.id {
            client.channels[id]?.isOpen = open
            
            if let delegate = client.groupEventsDelegate {
                delegate.groupOpened(group: channel)
            }
        }
    }
    
    //MARK: - Files
    func processFile(event: Event) {
        if let file = event.file, id = file.id {
            if let comment = file.initialComment, commentID = comment.id {
                if client.files[id]?.comments[commentID] == nil {
                    client.files[id]?.comments[commentID] = comment
                }
            }
            
            client.files[id] = file
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileProcessed(file: file)
            }
        }
    }
    
    func filePrivate(event: Event) {
        if let file =  event.file, id = file.id {
            client.files[id]?.isPublic = false
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileMadePrivate(file: file)
            }
        }
    }
    
    func deleteFile(event: Event) {
        if let file = event.file, id = file.id {
            if client.files[id] != nil {
                client.files.removeValue(forKey:id)
            }
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileDeleted(file: file)
            }
        }
    }
    
    func fileCommentAdded(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            client.files[id]?.comments[commentID] = comment
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileCommentAdded(file: file, comment: comment)
            }
        }
    }
    
    func fileCommentEdited(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            client.files[id]?.comments[commentID]?.comment = comment.comment
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileCommentEdited(file: file, comment: comment)
            }
        }
    }
    
    func fileCommentDeleted(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            client.files[id]?.comments.removeValue(forKey:commentID)
            
            if let delegate = client.fileEventsDelegate {
                delegate.fileCommentDeleted(file: file, comment: comment)
            }
        }
    }
    
    //MARK: - Pins
    func pinAdded(event: Event) {
        if let id = event.channelID, item = event.item {
            client.channels[id]?.pinnedItems.append(item)
            
            if let delegate = client.pinEventsDelegate {
                delegate.itemPinned(item: item, channel: client.channels[id])
            }
        }
    }
    
    func pinRemoved(event: Event) {
        if let id = event.channelID {
            if let pins = client.channels[id]?.pinnedItems.filter({$0 != event.item}) {
                client.channels[id]?.pinnedItems = pins
            }
            
            if let delegate = client.pinEventsDelegate {
                delegate.itemUnpinned(item: event.item, channel: client.channels[id])
            }
        }
    }
    
    //MARK: - Stars
    func itemStarred(event: Event, star: Bool) {
        if let item = event.item, type = item.type {
            switch type {
            case "message":
                starMessage(item: item, star: star)
            case "file":
                starFile(item: item, star: star)
            case "file_comment":
                starComment(item: item)
            default:
                break
            }
            
            if let delegate = client.starEventsDelegate {
                delegate.itemStarred(item: item, star: star)
            }
        }
    }
    
    func starMessage(item: Item, star: Bool) {
        if let message = item.message, ts = message.ts, channel = item.channel {
            if let _ = client.channels[channel]?.messages[ts] {
                client.channels[channel]?.messages[ts]?.isStarred = star
            }
        }
    }
    
    func starFile(item: Item, star: Bool) {
        if let file = item.file, id = file.id {
            client.files[id]?.isStarred = star
            if let stars = client.files[id]?.stars {
                if star == true {
                    client.files[id]?.stars = stars + 1
                } else {
                    if stars > 0 {
                        client.files[id]?.stars = stars - 1
                    }
                }
            }
        }
    }
    
    func starComment(item: Item) {
        if let file = item.file, id = file.id, comment = item.comment, commentID = comment.id {
            client.files[id]?.comments[commentID] = comment
        }
    }
    
    //MARK: - Reactions
    func addedReaction(event: Event) {
        if let item = event.item, type = item.type, key = event.reaction, userID = event.user?.id {
            switch type {
            case "message":
                if let channel = item.channel, ts = item.ts {
                    if let message = client.channels[channel]?.messages[ts] {
                        if (message.reactions[key]) == nil {
                            message.reactions[key] = Reaction(name: event.reaction, user: userID)
                        } else {
                            message.reactions[key]?.users[userID] = userID
                        }
                    }
                }
            case "file":
                if let id = item.file?.id, file = client.files[id] {
                    if file.reactions[key] == nil {
                        client.files[id]?.reactions[key] = Reaction(name: event.reaction, user: userID)
                    } else {
                        client.files[id]?.reactions[key]?.users[userID] = userID
                    }
                }
            case "file_comment":
                if let id = item.file?.id, file = client.files[id], commentID = item.fileCommentID {
                    if file.comments[commentID]?.reactions[key] == nil {
                        client.files[id]?.comments[commentID]?.reactions[key] = Reaction(name: event.reaction, user: userID)
                    } else {
                        client.files[id]?.comments[commentID]?.reactions[key]?.users[userID] = userID
                    }
                }
                break
            default:
                break
            }
            
            if let delegate = client.reactionEventsDelegate {
                delegate.reactionAdded(reaction: event.reaction, item: event.item, itemUser: event.itemUser)
            }
        }
    }
    
    func removedReaction(event: Event) {
        if let item = event.item, type = item.type, key = event.reaction, userID = event.user?.id {
            switch type {
            case "message":
                if let channel = item.channel, ts = item.ts {
                    if let message = client.channels[channel]?.messages[ts] {
                        if (message.reactions[key]) != nil {
                            message.reactions[key]?.users.removeValue(forKey:userID)
                        }
                        if (message.reactions[key]?.users.count == 0) {
                            message.reactions.removeValue(forKey:key)
                        }
                    }
                }
            case "file":
                if let itemFile = item.file, id = itemFile.id, file = client.files[id] {
                    if file.reactions[key] != nil {
                        client.files[id]?.reactions[key]?.users.removeValue(forKey:userID)
                    }
                    if client.files[id]?.reactions[key]?.users.count == 0 {
                        client.files[id]?.reactions.removeValue(forKey:key)
                    }
                }
            case "file_comment":
                if let id = item.file?.id, file = client.files[id], commentID = item.fileCommentID {
                    if file.comments[commentID]?.reactions[key] != nil {
                        client.files[id]?.comments[commentID]?.reactions[key]?.users.removeValue(forKey:userID)
                    }
                    if client.files[id]?.comments[commentID]?.reactions[key]?.users.count == 0 {
                        client.files[id]?.comments[commentID]?.reactions.removeValue(forKey:key)
                    }
                }
                break
            default:
                break
            }
            
            if let delegate = client.reactionEventsDelegate {
                delegate.reactionAdded(reaction: event.reaction, item: event.item, itemUser: event.itemUser)
            }
        }
    }
    
    //MARK: - Preferences
    func changePreference(event: Event) {
        if let name = event.name {
            client.authenticatedUser?.preferences?[name] = event.value
            
            if let delegate = client.slackEventsDelegate, value = event.value {
                delegate.preferenceChanged(preference: name, value: value)
            }
        }
    }
    
    //Mark: - User Change
    func userChange(event: Event) {
        if let user = event.user, id = user.id {
            let preferences = client.users[id]?.preferences
            client.users[id] = user
            client.users[id]?.preferences = preferences
            
            if let delegate = client.slackEventsDelegate {
                delegate.userChanged(user: user)
            }
        }
    }
    
    //MARK: - User Presence
    func presenceChange(event: Event) {
        if let user = event.user, id = user.id {
            client.users[id]?.presence = event.presence
            
            if let delegate = client.slackEventsDelegate {
                delegate.presenceChanged(user: user, presence: event.presence)
            }
        }
    }
    
    //MARK: - Team
    func teamJoin(event: Event) {
        if let user = event.user, id = user.id {
            client.users[id] = user
            
            if let delegate = client.teamEventsDelegate {
                delegate.teamJoined(user: user)
            }
        }
    }
    
    func teamPlanChange(event: Event) {
        if let plan = event.plan {
            client.team?.plan = plan
            
            if let delegate = client.teamEventsDelegate {
                delegate.teamPlanChanged(plan: plan)
            }
        }
    }
    
    func teamPreferenceChange(event: Event) {
        if let name = event.name {
            client.team?.prefs?[name] = event.value
            
            if let delegate = client.teamEventsDelegate, value = event.value {
                delegate.teamPreferencesChanged(preference: name, value: value)
            }
        }
    }
    
    func teamNameChange(event: Event) {
        if let name = event.name {
            client.team?.name = name
            
            if let delegate = client.teamEventsDelegate {
                delegate.teamNameChanged(name: name)
            }
        }
    }
    
    func teamDomainChange(event: Event) {
        if let domain = event.domain {
            client.team?.domain = domain
            
            if let delegate = client.teamEventsDelegate {
                delegate.teamDomainChanged(domain: domain)
            }
        }
    }
    
    func emailDomainChange(event: Event) {
        if let domain = event.emailDomain {
            client.team?.emailDomain = domain
            
            if let delegate = client.teamEventsDelegate {
                delegate.teamEmailDomainChanged(domain: domain)
            }
        }
    }
    
    func emojiChanged(event: Event) {
        //TODO: Call emoji.list here
        
        if let delegate = client.teamEventsDelegate {
            delegate.teamEmojiChanged()
        }
    }
    
    //MARK: - Bots
    func bot(event: Event) {
        if let bot = event.bot, id = bot.id {
            client.bots[id] = bot
            
            if let delegate = client.slackEventsDelegate {
                delegate.botEvent(bot: bot)
            }
        }
    }
    
    //MARK: - Subteams
    func subteam(event: Event) {
        if let subteam = event.subteam, id = subteam.id {
            client.userGroups[id] = subteam
            
            if let delegate = client.subteamEventsDelegate {
                delegate.subteamEvent(userGroup: subteam)
            }
        }
        
    }
    
    func subteamAddedSelf(event: Event) {
        if let subteamID = event.subteamID, _ = client.authenticatedUser?.userGroups {
            client.authenticatedUser?.userGroups![subteamID] = subteamID
            
            if let delegate = client.subteamEventsDelegate {
                delegate.subteamSelfAdded(subteamID: subteamID)
            }
        }
    }
    
    func subteamRemovedSelf(event: Event) {
        if let subteamID = event.subteamID {
            client.authenticatedUser?.userGroups?.removeValue(forKey:subteamID)
            
            if let delegate = client.subteamEventsDelegate {
                delegate.subteamSelfRemoved(subteamID: subteamID)
            }
        }
    }
    
    //MARK: - Team Profiles
    func teamProfileChange(event: Event) {
        for user in client.users {
            if let fields = event.profile?.fields {
                for key in fields.keys {
                    client.users[user.0]?.profile?.customProfile?.fields[key]?.updateProfileField(profile: fields[key])
                }
            }
        }
        
        if let delegate = client.teamProfileEventsDelegate {
            delegate.teamProfileChanged(profile: event.profile)
        }
    }
    
    func teamProfileDeleted(event: Event) {
        for user in client.users {
            if let id = event.profile?.fields.first?.0 {
                client.users[user.0]?.profile?.customProfile?.fields[id] = nil
            }
        }
        
        if let delegate = client.teamProfileEventsDelegate {
            delegate.teamProfileDeleted(profile: event.profile)
        }
    }
    
    func teamProfileReordered(event: Event) {
        for user in client.users {
            if let keys = event.profile?.fields.keys {
                for key in keys {
                    client.users[user.0]?.profile?.customProfile?.fields[key]?.ordering = event.profile?.fields[key]?.ordering
                }
            }
        }
        
        if let delegate = client.teamProfileEventsDelegate {
            delegate.teamProfileReordered(profile: event.profile)
        }
    }
    
    //MARK: - Authenticated User
    func manualPresenceChange(event: Event) {
        client.authenticatedUser?.presence = event.presence
        
        if let delegate = client.slackEventsDelegate {
            delegate.manualPresenceChanged(user: client.authenticatedUser, presence: event.presence)
        }
    }
    
}
