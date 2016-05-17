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

internal extension SlackClient {
    
    //MARK: - Pong
    func pong(event: Event) {
        pong = event.replyTo
    }
    
    //MARK: - Messages
    func messageSent(event: Event) {
        if let reply = event.replyTo, message = sentMessages["\(reply)"], channel = message.channel, ts = message.ts {
            message.ts = event.ts
            message.text = event.text
            channels[channel]?.messages[ts] = message
            
            messageEventsDelegate?.messageSent(message: message)
        }
    }
    
    func messageReceived(event: Event) {
        if let channel = event.channel, message = event.message, id = channel.id, ts = message.ts {
            channels[id]?.messages[ts] = message
            
            messageEventsDelegate?.messageReceived(message: message)
        }
    }
    
    func messageChanged(event: Event) {
        if let id = event.channel?.id, nested = event.nestedMessage, ts = nested.ts {
            channels[id]?.messages[ts] = nested
            
            messageEventsDelegate?.messageChanged(message: nested)
        }
    }
    
    func messageDeleted(event: Event) {
        if let id = event.channel?.id, key = event.message?.deletedTs {
            let message = channels[id]?.messages[key]
            channels[id]?.messages.removeValue(forKey:key)
            
            messageEventsDelegate?.messageDeleted(message: message)
        }
    }
    
    //MARK: - Channels
    func userTyping(event: Event) {
        if let channelID = event.channel?.id, userID = event.user?.id {
            if let _ = channels[channelID] {
                if (!channels[channelID]!.usersTyping.contains(userID)) {
                    channels[channelID]?.usersTyping.append(userID)
                    
                    channelEventsDelegate?.userTyping(channel: event.channel, user: event.user)
                }
            }
            
            /*let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
            dispatch_after(timeout, dispatch_get_main_queue()) {
                if let index = self.channels[channelID]?.usersTyping.index(of:userID) {
                    self.channels[channelID]?.usersTyping.remove(at: index)
                }
            }*/
        }
    }
    
    func channelMarked(event: Event) {
        if let channel = event.channel, id = channel.id {
            channels[id]?.lastRead = event.ts
            
            channelEventsDelegate?.channelMarked(channel: channel, timestamp: event.ts)
        }
        //TODO: Recalculate unreads
    }
    
    func channelCreated(event: Event) {
        if let channel = event.channel, id = channel.id {
            channels[id] = channel
            
            channelEventsDelegate?.channelCreated(channel: channel)
        }
    }
    
    func channelDeleted(event: Event) {
        if let channel = event.channel, id = channel.id {
            channels.removeValue(forKey:id)
            
            channelEventsDelegate?.channelDeleted(channel: channel)
        }
    }
    
    func channelJoined(event: Event) {
        if let channel = event.channel, id = channel.id {
            channels[id] = event.channel
            
            channelEventsDelegate?.channelJoined(channel: channel)
        }
    }
    
    func channelLeft(event: Event) {
        if let channel = event.channel, id = channel.id, userID = authenticatedUser?.id {
            if let index = channels[id]?.members?.index(of:userID) {
                channels[id]?.members?.remove(at: index)
                
                channelEventsDelegate?.channelLeft(channel: channel)
            }
        }
    }
    
    func channelRenamed(event: Event) {
        if let channel = event.channel, id = channel.id {
            channels[id]?.name = channel.name
            
            channelEventsDelegate?.channelRenamed(channel: channel)
        }
    }
    
    func channelArchived(event: Event, archived: Bool) {
        if let channel = event.channel, id = channel.id {
            channels[id]?.isArchived = archived
            
            channelEventsDelegate?.channelArchived(channel: channel)
        }
    }
    
    func channelHistoryChanged(event: Event) {
        if let channel = event.channel {
            //TODO: Reload chat history if there are any cached messages before latest
            
            channelEventsDelegate?.channelHistoryChanged(channel: channel)
        }
    }
    
    //MARK: - Do Not Disturb
    func doNotDisturbUpdated(event: Event) {
        if let dndStatus = event.dndStatus {
            authenticatedUser?.doNotDisturbStatus = dndStatus
            
            doNotDisturbEventsDelegate?.doNotDisturbUpdated(dndStatus: dndStatus)
        }
    }
    
    func doNotDisturbUserUpdated(event: Event) {
        if let dndStatus = event.dndStatus, user = event.user, id = user.id {
            users[id]?.doNotDisturbStatus = dndStatus
            
            doNotDisturbEventsDelegate?.doNotDisturbUserUpdated(dndStatus: dndStatus, user: user)
        }
    }
    
    //MARK: - IM & Group Open/Close
    func open(event: Event, open: Bool) {
        if let channel = event.channel, id = channel.id {
            channels[id]?.isOpen = open
            
            groupEventsDelegate?.groupOpened(group: channel)
        }
    }
    
    //MARK: - Files
    func processFile(event: Event) {
        if let file = event.file, id = file.id {
            if let comment = file.initialComment, commentID = comment.id {
                if files[id]?.comments[commentID] == nil {
                    files[id]?.comments[commentID] = comment
                }
            }
            
            files[id] = file
            
            fileEventsDelegate?.fileProcessed(file: file)
        }
    }
    
    func filePrivate(event: Event) {
        if let file =  event.file, id = file.id {
            files[id]?.isPublic = false
            
            fileEventsDelegate?.fileMadePrivate(file: file)
        }
    }
    
    func deleteFile(event: Event) {
        if let file = event.file, id = file.id {
            if files[id] != nil {
                files.removeValue(forKey:id)
            }
            
            fileEventsDelegate?.fileDeleted(file: file)
        }
    }
    
    func fileCommentAdded(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            files[id]?.comments[commentID] = comment
            
            fileEventsDelegate?.fileCommentAdded(file: file, comment: comment)
        }
    }
    
    func fileCommentEdited(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            files[id]?.comments[commentID]?.comment = comment.comment
            
            fileEventsDelegate?.fileCommentEdited(file: file, comment: comment)
        }
    }
    
    func fileCommentDeleted(event: Event) {
        if let file = event.file, id = file.id, comment = event.comment, commentID = comment.id {
            files[id]?.comments.removeValue(forKey:commentID)
            
            fileEventsDelegate?.fileCommentDeleted(file: file, comment: comment)
        }
    }
    
    //MARK: - Pins
    func pinAdded(event: Event) {
        if let id = event.channelID, item = event.item {
            channels[id]?.pinnedItems.append(item)
            
            pinEventsDelegate?.itemPinned(item: item, channel: channels[id])
        }
    }
    
    func pinRemoved(event: Event) {
        if let id = event.channelID {
            if let pins = channels[id]?.pinnedItems.filter({$0 != event.item}) {
                channels[id]?.pinnedItems = pins
            }
            
            pinEventsDelegate?.itemUnpinned(item: event.item, channel: channels[id])
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
            
            starEventsDelegate?.itemStarred(item: item, star: star)
        }
    }
    
    func starMessage(item: Item, star: Bool) {
        if let message = item.message, ts = message.ts, channel = item.channel {
            if let _ = channels[channel]?.messages[ts] {
                channels[channel]?.messages[ts]?.isStarred = star
            }
        }
    }
    
    func starFile(item: Item, star: Bool) {
        if let file = item.file, id = file.id {
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
    }
    
    func starComment(item: Item) {
        if let file = item.file, id = file.id, comment = item.comment, commentID = comment.id {
            files[id]?.comments[commentID] = comment
        }
    }
    
    //MARK: - Reactions
    func addedReaction(event: Event) {
        if let item = event.item, type = item.type, key = event.reaction, userID = event.user?.id {
            switch type {
            case "message":
                if let channel = item.channel, ts = item.ts {
                    if let message = channels[channel]?.messages[ts] {
                        if (message.reactions[key]) == nil {
                            message.reactions[key] = Reaction(name: event.reaction, user: userID)
                        } else {
                            message.reactions[key]?.users[userID] = userID
                        }
                    }
                }
            case "file":
                if let id = item.file?.id, file = files[id] {
                    if file.reactions[key] == nil {
                        files[id]?.reactions[key] = Reaction(name: event.reaction, user: userID)
                    } else {
                        files[id]?.reactions[key]?.users[userID] = userID
                    }
                }
            case "file_comment":
                if let id = item.file?.id, file = files[id], commentID = item.fileCommentID {
                    if file.comments[commentID]?.reactions[key] == nil {
                        files[id]?.comments[commentID]?.reactions[key] = Reaction(name: event.reaction, user: userID)
                    } else {
                        files[id]?.comments[commentID]?.reactions[key]?.users[userID] = userID
                    }
                }
                break
            default:
                break
            }
            
            reactionEventsDelegate?.reactionAdded(reaction: event.reaction, item: event.item, itemUser: event.itemUser)
        }
    }
    
    func removedReaction(event: Event) {
        if let item = event.item, type = item.type, key = event.reaction, userID = event.user?.id {
            switch type {
            case "message":
                if let channel = item.channel, ts = item.ts {
                    if let message = channels[channel]?.messages[ts] {
                        if (message.reactions[key]) != nil {
                            message.reactions[key]?.users.removeValue(forKey:userID)
                        }
                        if (message.reactions[key]?.users.count == 0) {
                            message.reactions.removeValue(forKey:key)
                        }
                    }
                }
            case "file":
                if let itemFile = item.file, id = itemFile.id, file = files[id] {
                    if file.reactions[key] != nil {
                        files[id]?.reactions[key]?.users.removeValue(forKey:userID)
                    }
                    if files[id]?.reactions[key]?.users.count == 0 {
                        files[id]?.reactions.removeValue(forKey:key)
                    }
                }
            case "file_comment":
                if let id = item.file?.id, file = files[id], commentID = item.fileCommentID {
                    if file.comments[commentID]?.reactions[key] != nil {
                        files[id]?.comments[commentID]?.reactions[key]?.users.removeValue(forKey:userID)
                    }
                    if files[id]?.comments[commentID]?.reactions[key]?.users.count == 0 {
                        files[id]?.comments[commentID]?.reactions.removeValue(forKey:key)
                    }
                }
                break
            default:
                break
            }
            
            reactionEventsDelegate?.reactionRemoved(reaction: event.reaction, item: event.item, itemUser: event.itemUser)
        }
    }
    
    //MARK: - Preferences
    func changePreference(event: Event) {
        if let name = event.name {
            authenticatedUser?.preferences?[name] = event.value
            
            slackEventsDelegate?.preferenceChanged(preference: name, value: event.value)
        }
    }
    
    //Mark: - User Change
    func userChange(event: Event) {
        if let user = event.user, id = user.id {
            let preferences = users[id]?.preferences
            users[id] = user
            users[id]?.preferences = preferences
            
            slackEventsDelegate?.userChanged(user: user)
        }
    }
    
    //MARK: - User Presence
    func presenceChange(event: Event) {
        if let user = event.user, id = user.id {
            users[id]?.presence = event.presence
            
            slackEventsDelegate?.presenceChanged(user: user, presence: event.presence)
        }
    }
    
    //MARK: - Team
    func teamJoin(event: Event) {
        if let user = event.user, id = user.id {
            users[id] = user
            
            teamEventsDelegate?.teamJoined(user: user)
        }
    }
    
    func teamPlanChange(event: Event) {
        if let plan = event.plan {
            team?.plan = plan
            
            teamEventsDelegate?.teamPlanChanged(plan: plan)
        }
    }
    
    func teamPreferenceChange(event: Event) {
        if let name = event.name {
            team?.prefs?[name] = event.value
            
            teamEventsDelegate?.teamPreferencesChanged(preference: name, value: event.value)
        }
    }
    
    func teamNameChange(event: Event) {
        if let name = event.name {
            team?.name = name
            
            teamEventsDelegate?.teamNameChanged(name: name)
        }
    }
    
    func teamDomainChange(event: Event) {
        if let domain = event.domain {
            team?.domain = domain
            
            teamEventsDelegate?.teamDomainChanged(domain: domain)
        }
    }
    
    func emailDomainChange(event: Event) {
        if let domain = event.emailDomain {
            team?.emailDomain = domain
            
            teamEventsDelegate?.teamEmailDomainChanged(domain: domain)
        }
    }
    
    func emojiChanged(event: Event) {
        //TODO: Call emoji.list here
        
        teamEventsDelegate?.teamEmojiChanged()
    }
    
    //MARK: - Bots
    func bot(event: Event) {
        if let bot = event.bot, id = bot.id {
            bots[id] = bot
            
            slackEventsDelegate?.botEvent(bot: bot)
        }
    }
    
    //MARK: - Subteams
    func subteam(event: Event) {
        if let subteam = event.subteam, id = subteam.id {
            userGroups[id] = subteam
            
            subteamEventsDelegate?.subteamEvent(userGroup: subteam)
        }
        
    }
    
    func subteamAddedSelf(event: Event) {
        if let subteamID = event.subteamID, _ = authenticatedUser?.userGroups {
            authenticatedUser?.userGroups![subteamID] = subteamID
            
            subteamEventsDelegate?.subteamSelfAdded(subteamID: subteamID)
        }
    }
    
    func subteamRemovedSelf(event: Event) {
        if let subteamID = event.subteamID {
            authenticatedUser?.userGroups?.removeValue(forKey:subteamID)
            
            subteamEventsDelegate?.subteamSelfRemoved(subteamID: subteamID)
        }
    }
    
    //MARK: - Team Profiles
    func teamProfileChange(event: Event) {
        for user in users {
            if let fields = event.profile?.fields {
                for key in fields.keys {
                    users[user.0]?.profile?.customProfile?.fields[key]?.updateProfileField(profile: fields[key])
                }
            }
        }
        
        teamProfileEventsDelegate?.teamProfileChanged(profile: event.profile)
    }
    
    func teamProfileDeleted(event: Event) {
        for user in users {
            if let id = event.profile?.fields.first?.0 {
                users[user.0]?.profile?.customProfile?.fields[id] = nil
            }
        }
        
        teamProfileEventsDelegate?.teamProfileDeleted(profile: event.profile)
    }
    
    func teamProfileReordered(event: Event) {
        for user in users {
            if let keys = event.profile?.fields.keys {
                for key in keys {
                    users[user.0]?.profile?.customProfile?.fields[key]?.ordering = event.profile?.fields[key]?.ordering
                }
            }
        }
        
        teamProfileEventsDelegate?.teamProfileReordered(profile: event.profile)
    }
    
    //MARK: - Authenticated User
    func manualPresenceChange(event: Event) {
        authenticatedUser?.presence = event.presence
        
        slackEventsDelegate?.manualPresenceChanged(user: authenticatedUser, presence: event.presence)
    }
    
}
