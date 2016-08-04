//
// Client+EventHandling.swift
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

internal extension Client {

    //MARK: - Pong
    func pong(_ event: Event) {
        pong = event.replyTo
    }
    
    //MARK: - Messages
    func messageSent(_ event: Event) {
        guard let reply = event.replyTo, let message = sentMessages[NSNumber(value: reply).stringValue], let channel = message.channel, let ts = message.ts else {
            return
        }
        
        message.ts = event.ts
        message.text = event.text
        channels[channel]?.messages[ts] = message
        messageEventsDelegate?.messageSent(self, message: message)
    }
    
    func messageReceived(_ event: Event) {
        guard let channel = event.channel, let message = event.message, let id = channel.id, let ts = message.ts else {
            return
        }
        
        channels[id]?.messages[ts] = message
        messageEventsDelegate?.messageReceived(self, message: message)
    }
    
    func messageChanged(_ event: Event) {
        guard let id = event.channel?.id, let nested = event.nestedMessage, let ts = nested.ts else {
            return
        }
        
        channels[id]?.messages[ts] = nested
        messageEventsDelegate?.messageChanged(self, message: nested)
    }
    
    func messageDeleted(_ event: Event) {
        guard let id = event.channel?.id, let key = event.message?.deletedTs, let message = channels[id]?.messages[key] else {
            return
        }
        
        _ = channels[id]?.messages.removeValue(forKey: key)
        messageEventsDelegate?.messageDeleted(self, message: message)
    }
    
    //MARK: - Channels
    func userTyping(_ event: Event) {
        guard let channel = event.channel, let channelID = channel.id, let user = event.user, let userID = user.id ,
            channels.index(forKey: channelID) != nil && !channels[channelID]!.usersTyping.contains(userID) else {
            return
        }

        channels[channelID]?.usersTyping.append(userID)
        channelEventsDelegate?.userTyping(self, channel: channel, user: user)

        let timeout = DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
            if let index = self.channels[channelID]?.usersTyping.index(of: userID) {
                self.channels[channelID]?.usersTyping.remove(at: index)
            }
        })
    }

    func channelMarked(_ event: Event) {
        guard let channel = event.channel, let id = channel.id, let timestamp = event.ts else {
            return
        }
        
        channels[id]?.lastRead = event.ts
        channelEventsDelegate?.channelMarked(self, channel: channel, timestamp: timestamp)
    }
    
    func channelCreated(_ event: Event) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels[id] = channel
        channelEventsDelegate?.channelCreated(self, channel: channel)
    }
    
    func channelDeleted(_ event: Event) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels.removeValue(forKey: id)
        channelEventsDelegate?.channelDeleted(self, channel: channel)
    }
    
    func channelJoined(_ event: Event) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels[id] = event.channel
        channelEventsDelegate?.channelJoined(self, channel: channel)
    }
    
    func channelLeft(_ event: Event) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        if let userID = authenticatedUser?.id, let index = channels[id]?.members?.index(of: userID) {
            channels[id]?.members?.remove(at: index)
        }
        channelEventsDelegate?.channelLeft(self, channel: channel)
    }
    
    func channelRenamed(_ event: Event) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels[id]?.name = channel.name
        channelEventsDelegate?.channelRenamed(self, channel: channel)
    }
    
    func channelArchived(_ event: Event, archived: Bool) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels[id]?.isArchived = archived
        channelEventsDelegate?.channelArchived(self, channel: channel)
    }
    
    func channelHistoryChanged(_ event: Event) {
        guard let channel = event.channel else {
            return
        }
        channelEventsDelegate?.channelHistoryChanged(self, channel: channel)
    }
    
    //MARK: - Do Not Disturb
    func doNotDisturbUpdated(_ event: Event) {
        guard let dndStatus = event.dndStatus else {
            return
        }
        
        authenticatedUser?.doNotDisturbStatus = dndStatus
        doNotDisturbEventsDelegate?.doNotDisturbUpdated(self, dndStatus: dndStatus)
    }
    
    func doNotDisturbUserUpdated(_ event: Event) {
        guard let dndStatus = event.dndStatus, let user = event.user, let id = user.id else {
            return
        }
        
        users[id]?.doNotDisturbStatus = dndStatus
        doNotDisturbEventsDelegate?.doNotDisturbUserUpdated(self, dndStatus: dndStatus, user: user)
    }
    
    //MARK: - IM & Group Open/Close
    func open(_ event: Event, open: Bool) {
        guard let channel = event.channel, let id = channel.id else {
            return
        }
        
        channels[id]?.isOpen = open
        groupEventsDelegate?.groupOpened(self, group: channel)
    }
    
    //MARK: - Files
    func processFile(_ event: Event) {
        guard let file = event.file, let id = file.id else {
            return
        }
        if let comment = file.initialComment, let commentID = comment.id {
            if files[id]?.comments[commentID] == nil {
                files[id]?.comments[commentID] = comment
            }
        }
            
        files[id] = file
        fileEventsDelegate?.fileProcessed(self, file: file)
    }
    
    func filePrivate(_ event: Event) {
        guard let file =  event.file, let id = file.id else {
            return
        }
        
        files[id]?.isPublic = false
        fileEventsDelegate?.fileMadePrivate(self, file: file)
    }
    
    func deleteFile(_ event: Event) {
        guard let file = event.file, let id = file.id else {
            return
        }
        
        if files[id] != nil {
            files.removeValue(forKey: id)
        }
        fileEventsDelegate?.fileDeleted(self, file: file)
    }
    
    func fileCommentAdded(_ event: Event) {
        guard let file = event.file, let id = file.id, let comment = event.comment, let commentID = comment.id else {
            return
        }
        
        files[id]?.comments[commentID] = comment
        fileEventsDelegate?.fileCommentAdded(self, file: file, comment: comment)
    }
    
    func fileCommentEdited(_ event: Event) {
        guard let file = event.file, let id = file.id, let comment = event.comment, let commentID = comment.id else {
            return
        }
        
        files[id]?.comments[commentID]?.comment = comment.comment
        fileEventsDelegate?.fileCommentEdited(self, file: file, comment: comment)
    }
    
    func fileCommentDeleted(_ event: Event) {
        guard let file = event.file, let id = file.id, let comment = event.comment, let commentID = comment.id else {
            return
        }
        
        _ = files[id]?.comments.removeValue(forKey: commentID)
        fileEventsDelegate?.fileCommentDeleted(self, file: file, comment: comment)
    }
    
    //MARK: - Pins
    func pinAdded(_ event: Event) {
        guard let id = event.channelID, let item = event.item else {
            return
        }
        
        channels[id]?.pinnedItems.append(item)
        pinEventsDelegate?.itemPinned(self, item: item, channel: channels[id])
    }
    
    func pinRemoved(_ event: Event) {
        guard let id = event.channelID, let item = event.item else {
            return
        }

        if let pins = channels[id]?.pinnedItems.filter({$0 != item}) {
            channels[id]?.pinnedItems = pins
        }
        pinEventsDelegate?.itemUnpinned(self, item: item, channel: channels[id])
    }

    //MARK: - Stars
    func itemStarred(_ event: Event, star: Bool) {
        guard let item = event.item, let type = item.type else {
            return
        }
        switch type {
        case "message":
            starMessage(item, star: star)
        case "file":
            starFile(item, star: star)
        case "file_comment":
            starComment(item)
        default:
            break
        }
            
        starEventsDelegate?.itemStarred(self, item: item, star: star)
    }
    
    func starMessage(_ item: Item, star: Bool) {
        guard let message = item.message, let ts = message.ts, let channel = item.channel , channels[channel]?.messages[ts] != nil else {
            return
        }
        channels[channel]?.messages[ts]?.isStarred = star
    }
    
    func starFile(_ item: Item, star: Bool) {
        guard let file = item.file, let id = file.id else {
            return
        }
        
        files[id]?.isStarred = star
        if let stars = files[id]?.stars {
            if star == true {
                files[id]?.stars = stars + 1
            } else {
                if stars > 0 {
                    files[id]?.stars = stars - 1
                }
            }
        }
    }
    
    func starComment(_ item: Item) {
        guard let file = item.file, let id = file.id, let comment = item.comment, let commentID = comment.id else {
            return
        }
        files[id]?.comments[commentID] = comment
    }
    
    //MARK: - Reactions
    func addedReaction(_ event: Event) {
        guard let item = event.item, let type = item.type, let reaction = event.reaction, let userID = event.user?.id, let itemUser = event.itemUser else {
            return
        }
        
        switch type {
        case "message":
            guard let channel = item.channel, let ts = item.ts, let message = channels[channel]?.messages[ts] else {
                return
            }
            message.reactions.append(Reaction(name: reaction, user: userID))
        case "file":
            guard let id = item.file?.id else {
                return
            }
            files[id]?.reactions.append(Reaction(name: reaction, user: userID))
        case "file_comment":
            guard let id = item.file?.id, let commentID = item.fileCommentID else {
                return
            }
            files[id]?.comments[commentID]?.reactions.append(Reaction(name: reaction, user: userID))
        default:
            break
        }

        reactionEventsDelegate?.reactionAdded(self, reaction: reaction, item: item, itemUser: itemUser)
    }

    func removedReaction(_ event: Event) {
        guard let item = event.item, let type = item.type, let key = event.reaction, let userID = event.user?.id, let itemUser = event.itemUser else {
            return
        }

        switch type {
        case "message":
            guard let channel = item.channel, let ts = item.ts, let message = channels[channel]?.messages[ts] else {
                return
            }
            message.reactions = message.reactions.filter({$0.name != key && $0.user != userID})
        case "file":
            guard let itemFile = item.file, let id = itemFile.id else {
                return
            }
            files[id]?.reactions = files[id]!.reactions.filter({$0.name != key && $0.user != userID})
        case "file_comment":
            guard let id = item.file?.id, let commentID = item.fileCommentID else {
                return
            }
            files[id]?.comments[commentID]?.reactions = files[id]!.comments[commentID]!.reactions.filter({$0.name != key && $0.user != userID})
        default:
            break
        }

        reactionEventsDelegate?.reactionRemoved(self, reaction: key, item: item, itemUser: itemUser)
    }

    //MARK: - Preferences
    func changePreference(_ event: Event) {
        guard let name = event.name else {
            return
        }
        
        authenticatedUser?.preferences?[name] = event.value
        slackEventsDelegate?.preferenceChanged(self, preference: name, value: event.value)
    }
    
    //Mark: - User Change
    func userChange(_ event: Event) {
        guard let user = event.user, let id = user.id else {
            return
        }
        
        let preferences = users[id]?.preferences
        users[id] = user
        users[id]?.preferences = preferences
        slackEventsDelegate?.userChanged(self, user: user)
    }
    
    //MARK: - User Presence
    func presenceChange(_ event: Event) {
        guard let user = event.user, let id = user.id, let presence = event.presence else {
            return
        }
        
        users[id]?.presence = event.presence
        slackEventsDelegate?.presenceChanged(self, user: user, presence: presence)
    }
    
    //MARK: - Team
    func teamJoin(_ event: Event) {
        guard let user = event.user, let id = user.id else {
            return
        }
        
        users[id] = user
        teamEventsDelegate?.teamJoined(self, user: user)
    }
    
    func teamPlanChange(_ event: Event) {
        guard let plan = event.plan else {
            return
        }
        
        team?.plan = plan
        teamEventsDelegate?.teamPlanChanged(self, plan: plan)
    }
    
    func teamPreferenceChange(_ event: Event) {
        guard let name = event.name else {
            return
        }
        
        team?.prefs?[name] = event.value
        teamEventsDelegate?.teamPreferencesChanged(self, preference: name, value: event.value)
    }
    
    func teamNameChange(_ event: Event) {
        guard let name = event.name else {
            return
        }
        
        team?.name = name
        teamEventsDelegate?.teamNameChanged(self, name: name)
    }
    
    func teamDomainChange(_ event: Event) {
        guard let domain = event.domain else {
            return
        }
        
        team?.domain = domain
        teamEventsDelegate?.teamDomainChanged(self, domain: domain)
    }
    
    func emailDomainChange(_ event: Event) {
        guard let domain = event.emailDomain else {
            return
        }
        
        team?.emailDomain = domain
        teamEventsDelegate?.teamEmailDomainChanged(self, domain: domain)
    }
    
    func emojiChanged(_ event: Event) {
        teamEventsDelegate?.teamEmojiChanged(self)
    }
    
    //MARK: - Bots
    func bot(_ event: Event) {
        guard let bot = event.bot, let id = bot.id else {
            return
        }
        
        bots[id] = bot
        slackEventsDelegate?.botEvent(self, bot: bot)
    }
    
    //MARK: - Subteams
    func subteam(_ event: Event) {
        guard let subteam = event.subteam, let id = subteam.id else {
            return
        }
        
        userGroups[id] = subteam
        subteamEventsDelegate?.subteamEvent(self, userGroup: subteam)
    }
    
    func subteamAddedSelf(_ event: Event) {
        guard let subteamID = event.subteamID, let _ = authenticatedUser?.userGroups else {
            return
        }
        
        authenticatedUser?.userGroups![subteamID] = subteamID
        subteamEventsDelegate?.subteamSelfAdded(self, subteamID: subteamID)
    }
    
    func subteamRemovedSelf(_ event: Event) {
        guard let subteamID = event.subteamID else {
            return
        }
        
        _ = authenticatedUser?.userGroups?.removeValue(forKey: subteamID)
        subteamEventsDelegate?.subteamSelfRemoved(self, subteamID: subteamID)
    }
    
    //MARK: - Team Profiles
    func teamProfileChange(_ event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            for key in profile.fields.keys {
                users[user.0]?.profile?.customProfile?.fields[key]?.updateProfileField(profile.fields[key])
            }
        }
        
        teamProfileEventsDelegate?.teamProfileChanged(self, profile: profile)
    }
    
    func teamProfileDeleted(_ event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            if let id = profile.fields.first?.0 {
                users[user.0]?.profile?.customProfile?.fields[id] = nil
            }
        }
        
        teamProfileEventsDelegate?.teamProfileDeleted(self, profile: profile)
    }
    
    func teamProfileReordered(_ event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            for key in profile.fields.keys {
                users[user.0]?.profile?.customProfile?.fields[key]?.ordering = profile.fields[key]?.ordering
            }
        }

        teamProfileEventsDelegate?.teamProfileReordered(self, profile: profile)
    }
    
    //MARK: - Authenticated User
    func manualPresenceChange(_ event: Event) {
        guard let presence = event.presence, let user = authenticatedUser else {
            return
        }
        
        authenticatedUser?.presence = presence
        slackEventsDelegate?.manualPresenceChanged(self, user: user, presence: presence)
    }
    
}
