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
    func pong(event: Event) {
        pong = event.replyTo
    }
    
    //MARK: - Messages
    func messageSent(event: Event) {
        guard let reply = event.replyTo, message = sentMessages[NSNumber(double: reply).stringValue], channel = message.channel, ts = message.ts else {
            return
        }
        
        message.ts = event.ts
        message.text = event.text
        channels[channel]?.messages[ts] = message
        messageEventsDelegate?.messageSent(message)
    }
    
    func messageReceived(event: Event) {
        guard let channel = event.channel, message = event.message, id = channel.id, ts = message.ts else {
            return
        }
        
        channels[id]?.messages[ts] = message
        messageEventsDelegate?.messageReceived(message)
    }
    
    func messageChanged(event: Event) {
        guard let id = event.channel?.id, nested = event.nestedMessage, ts = nested.ts else {
            return
        }
        
        channels[id]?.messages[ts] = nested
        messageEventsDelegate?.messageChanged(nested)
    }
    
    func messageDeleted(event: Event) {
        guard let id = event.channel?.id, key = event.message?.deletedTs, message = channels[id]?.messages[key] else {
            return
        }
        
        channels[id]?.messages.removeValueForKey(key)
        messageEventsDelegate?.messageDeleted(message)
    }
    
    //MARK: - Channels
    func userTyping(event: Event) {
        guard let channel = event.channel, channelID = channel.id, user = event.user, userID = user.id where
            channels.indexForKey(channelID) != nil && !channels[channelID]!.usersTyping.contains(userID) else {
            return
        }

        channels[channelID]?.usersTyping.append(userID)
        channelEventsDelegate?.userTyping(channel, user: user)

        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
        dispatch_after(timeout, dispatch_get_main_queue()) {
            if let index = self.channels[channelID]?.usersTyping.indexOf(userID) {
                self.channels[channelID]?.usersTyping.removeAtIndex(index)
            }
        }
    }

    func channelMarked(event: Event) {
        guard let channel = event.channel, id = channel.id, timestamp = event.ts else {
            return
        }
        
        channels[id]?.lastRead = event.ts
        channelEventsDelegate?.channelMarked(channel, timestamp: timestamp)
    }
    
    func channelCreated(event: Event) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels[id] = channel
        channelEventsDelegate?.channelCreated(channel)
    }
    
    func channelDeleted(event: Event) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels.removeValueForKey(id)
        channelEventsDelegate?.channelDeleted(channel)
    }
    
    func channelJoined(event: Event) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels[id] = event.channel
        channelEventsDelegate?.channelJoined(channel)
    }
    
    func channelLeft(event: Event) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        if let userID = authenticatedUser?.id, index = channels[id]?.members?.indexOf(userID) {
            channels[id]?.members?.removeAtIndex(index)
        }
        channelEventsDelegate?.channelLeft(channel)
    }
    
    func channelRenamed(event: Event) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels[id]?.name = channel.name
        channelEventsDelegate?.channelRenamed(channel)
    }
    
    func channelArchived(event: Event, archived: Bool) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels[id]?.isArchived = archived
        channelEventsDelegate?.channelArchived(channel)
    }
    
    func channelHistoryChanged(event: Event) {
        guard let channel = event.channel else {
            return
        }
        channelEventsDelegate?.channelHistoryChanged(channel)
    }
    
    //MARK: - Do Not Disturb
    func doNotDisturbUpdated(event: Event) {
        guard let dndStatus = event.dndStatus else {
            return
        }
        
        authenticatedUser?.doNotDisturbStatus = dndStatus
        doNotDisturbEventsDelegate?.doNotDisturbUpdated(dndStatus)
    }
    
    func doNotDisturbUserUpdated(event: Event) {
        guard let dndStatus = event.dndStatus, user = event.user, id = user.id else {
            return
        }
        
        users[id]?.doNotDisturbStatus = dndStatus
        doNotDisturbEventsDelegate?.doNotDisturbUserUpdated(dndStatus, user: user)
    }
    
    //MARK: - IM & Group Open/Close
    func open(event: Event, open: Bool) {
        guard let channel = event.channel, id = channel.id else {
            return
        }
        
        channels[id]?.isOpen = open
        groupEventsDelegate?.groupOpened(channel)
    }
    
    //MARK: - Files
    func processFile(event: Event) {
        guard let file = event.file, id = file.id else {
            return
        }
        if let comment = file.initialComment, commentID = comment.id {
            if files[id]?.comments[commentID] == nil {
                files[id]?.comments[commentID] = comment
            }
        }
            
        files[id] = file
        fileEventsDelegate?.fileProcessed(file)
    }
    
    func filePrivate(event: Event) {
        guard let file =  event.file, id = file.id else {
            return
        }
        
        files[id]?.isPublic = false
        fileEventsDelegate?.fileMadePrivate(file)
    }
    
    func deleteFile(event: Event) {
        guard let file = event.file, id = file.id else {
            return
        }
        
        if files[id] != nil {
            files.removeValueForKey(id)
        }
        fileEventsDelegate?.fileDeleted(file)
    }
    
    func fileCommentAdded(event: Event) {
        guard let file = event.file, id = file.id, comment = event.comment, commentID = comment.id else {
            return
        }
        
        files[id]?.comments[commentID] = comment
        fileEventsDelegate?.fileCommentAdded(file, comment: comment)
    }
    
    func fileCommentEdited(event: Event) {
        guard let file = event.file, id = file.id, comment = event.comment, commentID = comment.id else {
            return
        }
        
        files[id]?.comments[commentID]?.comment = comment.comment
        fileEventsDelegate?.fileCommentEdited(file, comment: comment)
    }
    
    func fileCommentDeleted(event: Event) {
        guard let file = event.file, id = file.id, comment = event.comment, commentID = comment.id else {
            return
        }
        
        files[id]?.comments.removeValueForKey(commentID)
        fileEventsDelegate?.fileCommentDeleted(file, comment: comment)
    }
    
    //MARK: - Pins
    func pinAdded(event: Event) {
        guard let id = event.channelID, item = event.item else {
            return
        }
        
        channels[id]?.pinnedItems.append(item)
        pinEventsDelegate?.itemPinned(item, channel: channels[id])
    }
    
    func pinRemoved(event: Event) {
        guard let id = event.channelID, item = event.item else {
            return
        }

        if let pins = channels[id]?.pinnedItems.filter({$0 != item}) {
            channels[id]?.pinnedItems = pins
        }
        pinEventsDelegate?.itemUnpinned(item, channel: channels[id])
    }

    //MARK: - Stars
    func itemStarred(event: Event, star: Bool) {
        guard let item = event.item, type = item.type else {
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
            
        starEventsDelegate?.itemStarred(item, star: star)
    }
    
    func starMessage(item: Item, star: Bool) {
        guard let message = item.message, ts = message.ts, channel = item.channel where channels[channel]?.messages[ts] != nil else {
            return
        }
        channels[channel]?.messages[ts]?.isStarred = star
    }
    
    func starFile(item: Item, star: Bool) {
        guard let file = item.file, id = file.id else {
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
    
    func starComment(item: Item) {
        guard let file = item.file, id = file.id, comment = item.comment, commentID = comment.id else {
            return
        }
        files[id]?.comments[commentID] = comment
    }
    
    //MARK: - Reactions
    func addedReaction(event: Event) {
        guard let item = event.item, type = item.type, reaction = event.reaction, userID = event.user?.id, itemUser = event.itemUser else {
            return
        }
        
        switch type {
        case "message":
            guard let channel = item.channel, ts = item.ts, message = channels[channel]?.messages[ts] else {
                return
            }
            message.reactions.append(Reaction(name: reaction, user: userID))
        case "file":
            guard let id = item.file?.id else {
                return
            }
            files[id]?.reactions.append(Reaction(name: reaction, user: userID))
        case "file_comment":
            guard let id = item.file?.id, commentID = item.fileCommentID else {
                return
            }
            files[id]?.comments[commentID]?.reactions.append(Reaction(name: reaction, user: userID))
        default:
            break
        }

        reactionEventsDelegate?.reactionAdded(reaction, item: item, itemUser: itemUser)
    }

    func removedReaction(event: Event) {
        guard let item = event.item, type = item.type, key = event.reaction, userID = event.user?.id, itemUser = event.itemUser else {
            return
        }

        switch type {
        case "message":
            guard let channel = item.channel, ts = item.ts, message = channels[channel]?.messages[ts] else {
                return
            }
            message.reactions = message.reactions.filter({$0.name != key && $0.user != userID})
        case "file":
            guard let itemFile = item.file, id = itemFile.id else {
                return
            }
            files[id]?.reactions = files[id]!.reactions.filter({$0.name != key && $0.user != userID})
        case "file_comment":
            guard let id = item.file?.id, commentID = item.fileCommentID else {
                return
            }
            files[id]?.comments[commentID]?.reactions = files[id]!.comments[commentID]!.reactions.filter({$0.name != key && $0.user != userID})
        default:
            break
        }

        reactionEventsDelegate?.reactionRemoved(key, item: item, itemUser: itemUser)
    }

    //MARK: - Preferences
    func changePreference(event: Event) {
        guard let name = event.name else {
            return
        }
        
        authenticatedUser?.preferences?[name] = event.value
        slackEventsDelegate?.preferenceChanged(name, value: event.value)
    }
    
    //Mark: - User Change
    func userChange(event: Event) {
        guard let user = event.user, id = user.id else {
            return
        }
        
        let preferences = users[id]?.preferences
        users[id] = user
        users[id]?.preferences = preferences
        slackEventsDelegate?.userChanged(user)
    }
    
    //MARK: - User Presence
    func presenceChange(event: Event) {
        guard let user = event.user, id = user.id, presence = event.presence else {
            return
        }
        
        users[id]?.presence = event.presence
        slackEventsDelegate?.presenceChanged(user, presence: presence)
    }
    
    //MARK: - Team
    func teamJoin(event: Event) {
        guard let user = event.user, id = user.id else {
            return
        }
        
        users[id] = user
        teamEventsDelegate?.teamJoined(user)
    }
    
    func teamPlanChange(event: Event) {
        guard let plan = event.plan else {
            return
        }
        
        team?.plan = plan
        teamEventsDelegate?.teamPlanChanged(plan)
    }
    
    func teamPreferenceChange(event: Event) {
        guard let name = event.name else {
            return
        }
        
        team?.prefs?[name] = event.value
        teamEventsDelegate?.teamPreferencesChanged(name, value: event.value)
    }
    
    func teamNameChange(event: Event) {
        guard let name = event.name else {
            return
        }
        
        team?.name = name
        teamEventsDelegate?.teamNameChanged(name)
    }
    
    func teamDomainChange(event: Event) {
        guard let domain = event.domain else {
            return
        }
        
        team?.domain = domain
        teamEventsDelegate?.teamDomainChanged(domain)
    }
    
    func emailDomainChange(event: Event) {
        guard let domain = event.emailDomain else {
            return
        }
        
        team?.emailDomain = domain
        teamEventsDelegate?.teamEmailDomainChanged(domain)
    }
    
    func emojiChanged(event: Event) {
        teamEventsDelegate?.teamEmojiChanged()
    }
    
    //MARK: - Bots
    func bot(event: Event) {
        guard let bot = event.bot, id = bot.id else {
            return
        }
        
        bots[id] = bot
        slackEventsDelegate?.botEvent(bot)
    }
    
    //MARK: - Subteams
    func subteam(event: Event) {
        guard let subteam = event.subteam, id = subteam.id else {
            return
        }
        
        userGroups[id] = subteam
        subteamEventsDelegate?.subteamEvent(subteam)
    }
    
    func subteamAddedSelf(event: Event) {
        guard let subteamID = event.subteamID, _ = authenticatedUser?.userGroups else {
            return
        }
        
        authenticatedUser?.userGroups![subteamID] = subteamID
        subteamEventsDelegate?.subteamSelfAdded(subteamID)
    }
    
    func subteamRemovedSelf(event: Event) {
        guard let subteamID = event.subteamID else {
            return
        }
        
        authenticatedUser?.userGroups?.removeValueForKey(subteamID)
        subteamEventsDelegate?.subteamSelfRemoved(subteamID)
    }
    
    //MARK: - Team Profiles
    func teamProfileChange(event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            for key in profile.fields.keys {
                users[user.0]?.profile?.customProfile?.fields[key]?.updateProfileField(profile.fields[key])
            }
        }
        
        teamProfileEventsDelegate?.teamProfileChanged(profile)
    }
    
    func teamProfileDeleted(event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            if let id = profile.fields.first?.0 {
                users[user.0]?.profile?.customProfile?.fields[id] = nil
            }
        }
        
        teamProfileEventsDelegate?.teamProfileDeleted(profile)
    }
    
    func teamProfileReordered(event: Event) {
        guard let profile = event.profile else {
            return
        }

        for user in users {
            for key in profile.fields.keys {
                users[user.0]?.profile?.customProfile?.fields[key]?.ordering = profile.fields[key]?.ordering
            }
        }

        teamProfileEventsDelegate?.teamProfileReordered(profile)
    }
    
    //MARK: - Authenticated User
    func manualPresenceChange(event: Event) {
        guard let presence = event.presence, user = authenticatedUser else {
            return
        }
        
        authenticatedUser?.presence = presence
        slackEventsDelegate?.manualPresenceChanged(user, presence: presence)
    }
    
}
