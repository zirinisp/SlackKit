//
// EventHandler.swift
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

import Foundation

internal struct EventHandler {
    
    //MARK: - Initial connection
    static func connected() {
        Client.sharedInstance.connected = true
        
        if let delegate = Client.sharedInstance.slackEventsDelegate {
            delegate.clientConnected()
        }
    }
    
    //MARK: - Messages
    
    static func messageSent(event: Event) {
        if let reply = event.replyTo {
            if let message = Client.sharedInstance.sentMessages[reply] {
                message.ts = event.ts
                message.text = event.text
                Client.sharedInstance.channels?[message.channel!]?.messages[message.ts!] = message
                
                if let delegate = Client.sharedInstance.messageEventsDelegate {
                    delegate.messageSent(message)
                }
            }
        }
    }
    
    static func messageReceived(event: Event) {
        if let channel = event.channel,
            message = event.message
        {
            Client.sharedInstance.channels?[channel.id!]?.messages[message.ts!] = message
            
            if let delegate = Client.sharedInstance.messageEventsDelegate {
                delegate.messageReceived(message)
            }
        }
    }
    
    static func messageChanged(event: Event) {
        if let id = event.channel?.id {
            if let nested = event.nestedMessage {
                Client.sharedInstance.channels?[id]?.messages[nested.ts!] = nested
                
                if let delegate = Client.sharedInstance.messageEventsDelegate {
                    delegate.messageChanged(nested)
                }
            }
        }
    }
    
    static func messageDeleted(event: Event) {
        if let id = event.channel?.id {
            if let key = event.message?.deletedTs {
                let message = Client.sharedInstance.channels?[id]?.messages[key]
                Client.sharedInstance.channels?[id]?.messages.removeValueForKey(key)
                
                if let delegate = Client.sharedInstance.messageEventsDelegate {
                    delegate.messageDeleted(message)
                }
            }
        }
    }
    
    //MARK: - Channels
    static func userTyping(event: Event) {
        if (!Client.sharedInstance.channels![event.channel!.id!]!.usersTyping.contains(event.user!.id!)) {
            Client.sharedInstance.channels?[event.channel!.id!]?.usersTyping.append(event.user!.id!)
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.userTyping(event.channel!, user: event.user!)
            }
        }
        
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
        dispatch_after(timeout, dispatch_get_main_queue()) {
            if let index = Client.sharedInstance.channels?[event.channel!.id!]?.usersTyping.indexOf(event.user!.id!) {
                Client.sharedInstance.channels?[event.channel!.id!]?.usersTyping.removeAtIndex(index)
            }
        }
    }
    
    static func channelMarked(event: Event) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!]?.lastRead = event.ts
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelMarked(channel, timestamp: event.ts!)
            }
        }
        //TODO: Recalculate unreads
    }
    
    static func channelCreated(event: Event) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!] = channel
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelCreated(channel)
            }
        }
    }
    
    static func channelDeleted(event: Event) {
        if let channel = event.channel {
            Client.sharedInstance.channels?.removeValueForKey(channel.id!)
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelDeleted(channel)
            }
        }
    }
    
    static func channelJoined(event: Event) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!]?.members.append(Client.sharedInstance.authenticatedUser!.id!)
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelJoined(channel, user: Client.sharedInstance.authenticatedUser!)
            }
        }
    }
    
    static func channelLeft(event: Event) {
        if let channel = event.channel {
            if let index = Client.sharedInstance.channels?[channel.id!]?.members.indexOf(Client.sharedInstance.authenticatedUser!.id!) {
                Client.sharedInstance.channels?[channel.id!]?.members.removeAtIndex(index)
                
                if let delegate = Client.sharedInstance.channelEventsDelegate {
                    delegate.channelLeft(channel, user: Client.sharedInstance.authenticatedUser!)
                }
            }
        }
    }
    
    static func channelRenamed(event: Event) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!]?.name = channel.name
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelRenamed(channel)
            }
        }
    }
    
    static func channelArchived(event: Event, archived: Bool) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!]?.isArchived = archived
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelArchived(channel)
            }
        }
    }
    
    static func channelHistoryChanged(event: Event) {
        if let channel = event.channel {
            //TODO: Reload chat history if there are any cached messages before latest
            
            if let delegate = Client.sharedInstance.channelEventsDelegate {
                delegate.channelHistoryChanged(channel)
            }
        }
    }
    
    //MARK: - DM & Group Open/Close
    static func open(event: Event, open: Bool) {
        if let channel = event.channel {
            Client.sharedInstance.channels?[channel.id!]?.isOpen = open
            
            if let delegate = Client.sharedInstance.groupEventsDelegate {
                delegate.groupOpened(channel)
            }
        }
    }
    
    //MARK: - Files
    static func processFile(event: Event) {
        if let file = event.file {
            Client.sharedInstance.files[file.id!] = file
            
            if let delegate = Client.sharedInstance.fileEventsDelegate {
                delegate.fileProcessed(file)
            }
        }
    }
    
    static func filePrivate(event: Event) {
        if let file =  event.file {
            Client.sharedInstance.files[file.id!]?.isPublic = false
            
            if let delegate = Client.sharedInstance.fileEventsDelegate {
                delegate.fileMadePrivate(file)
            }
        }
    }
    
    static func deleteFile(event: Event) {
        if let file = event.file {
            if Client.sharedInstance.files[event.fileID!] != nil {
                Client.sharedInstance.files.removeValueForKey(event.fileID!)
            }
            
            if let delegate = Client.sharedInstance.fileEventsDelegate {
                delegate.fileDeleted(file)
            }
        }
    }
    
    static func fileCommentAdded(event: Event) {
        if let file = event.file {
            if let comment = event.comment {
                Client.sharedInstance.files[file.id!]?.comments?.append(comment)
                
                if let delegate = Client.sharedInstance.fileEventsDelegate {
                    delegate.fileCommentAdded(file, comment: comment)
                }
            }
        }
    }
    
    static func fileCommentEdited(event: Event) {
        if let file = event.file {
            if let commentEdit = event.comment {
                if let comments = Client.sharedInstance.files[file.id!]?.comments?.filter({$0.id == commentEdit.id}) {
                    if var comment = comments.first {
                        comment.comment = commentEdit.comment
                        comment.timestamp = commentEdit.timestamp
                        
                        if let delegate = Client.sharedInstance.fileEventsDelegate {
                            delegate.fileCommentEdited(file, comment: comment)
                        }
                    }
                }
            }
        }
    }
    
    static func fileCommentDeleted(event: Event) {
        if let file = event.file {
            if let comment = event.comment {
                if let comments = Client.sharedInstance.files[file.id!]?.comments?.filter({$0.id != comment.id}) {
                    Client.sharedInstance.files[file.id!]?.comments = comments
                }
                
                if let delegate = Client.sharedInstance.fileEventsDelegate {
                    delegate.fileCommentDeleted(file, comment: comment)
                }
            }
        }
    }
    
    //MARK: - Pins
    static func pinAdded(event: Event) {
        if let id = event.channelID {
            Client.sharedInstance.channels?[id]?.pinnedItems.append(event.item!)
            
            if let delegate = Client.sharedInstance.pinEventsDelegate {
                delegate.itemPinned(event.item!, channel: Client.sharedInstance.channels![id]!)
            }
        }
    }
    
    static func pinRemoved(event: Event) {
        if let id = event.channelID {
            if let pins = Client.sharedInstance.channels?[id]?.pinnedItems.filter({$0 != event.item}) {
                Client.sharedInstance.channels?[id]?.pinnedItems = pins
            }
            
            if let delegate = Client.sharedInstance.pinEventsDelegate {
                delegate.itemUnpinned(event.item!, channel: Client.sharedInstance.channels![id]!)
            }
        }
    }
    
    //MARK: - Stars
    static func messageStarred(event: Event, star: Bool) {
        if let item = event.item {
            if let message = Client.sharedInstance.channels?[item.channel!]?.messages[item.message!.ts!] {
                message.isStarred = star
                
                if let delegate = Client.sharedInstance.starEventsDelegate {
                    delegate.messageStarred(Client.sharedInstance.channels![item.channel!]!, message: message, star: star)
                }
            }
        }
    }
    
    //MARK: - Reactions
    static func addedReaction(event: Event) {
        if let channel = event.item?.channel {
            if let message = Client.sharedInstance.channels?[channel]?.messages[event.item!.ts!] {
                if (message.reactions[event.reaction!]) == nil {
                    message.reactions[event.reaction!] = Reaction(name: event.reaction, user: event.user!.id!)
                } else {
                    message.reactions[event.reaction!]?.users[event.user!.id!] = event.user!.id!
                }
                
                if let delegate = Client.sharedInstance.reactionEventsDelegate {
                    delegate.reactionAdded(message.reactions[event.reaction!]!, channel: Client.sharedInstance.channels![channel]!, message: message)
                }
            }
        }
    }
    
    static func removedReaction(event: Event) {
        if let channel = event.item?.channel {
            if let message = Client.sharedInstance.channels?[channel]?.messages[event.item!.ts!] {
                let reaction = message.reactions[event.reaction!]
                if (message.reactions[event.reaction!]) != nil {
                    message.reactions[event.reaction!]?.users.removeValueForKey(event.user!.id!)
                }
                if (message.reactions[event.reaction!]?.users.count == 0) {
                    message.reactions.removeValueForKey(event.reaction!)
                }
                
                if let delegate = Client.sharedInstance.reactionEventsDelegate {
                    delegate.reactionRemoved(reaction!, channel: Client.sharedInstance.channels![channel]!, message: message)
                }
            }
        }
    }
    
    //MARK: - Preferences
    static func changePreference(event: Event) {
        if let name = event.name {
            Client.sharedInstance.authenticatedUser?.preferences?[name] = event.value
            
            if let delegate = Client.sharedInstance.slackEventsDelegate {
                if let value = event.value {
                    delegate.preferenceChanged(name, value: value)
                }
            }
        }
    }
    
    //Mark: - User Change
    static func userChange(event: Event) {
        if var user = event.user {
            user.preferences = Client.sharedInstance.users?[user.id!]?.preferences
            Client.sharedInstance.users?[user.id!] = user
            
            if let delegate = Client.sharedInstance.slackEventsDelegate {
                delegate.userChanged(user)
            }
        }
    }
    
    //MARK: - User Presence
    static func presenceChange(event: Event) {
        if let user = event.user {
            Client.sharedInstance.users?[user.id!]?.presence = event.presence
            
            if let delegate = Client.sharedInstance.slackEventsDelegate {
                delegate.presenceChanged(user, presence: event.presence!)
            }
        }
    }
    
    //MARK: - Team
    static func teamJoin(event: Event) {
        if let user = event.user {
            Client.sharedInstance.users?[user.id!] = user
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                delegate.teamJoined(user)
            }
        }
    }
    
    static func teamPlanChange(event: Event) {
        if let plan = event.plan {
            Client.sharedInstance.team?.plan = plan
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                delegate.teamPlanChanged(plan)
            }
        }
    }
    
    static func teamPreferenceChange(event: Event) {
        if let name = event.name {
            Client.sharedInstance.team?.prefs?[name] = event.value
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                if let value = event.value {
                    delegate.teamPreferencesChanged(name, value: value)
                }
            }
        }
    }
    
    static func teamNameChange(event: Event) {
        if let name = event.name {
            Client.sharedInstance.team?.name = name
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                delegate.teamNameChanged(name)
            }
        }
    }
    
    static func teamDomainChange(event: Event) {
        if let domain = event.domain {
            Client.sharedInstance.team?.domain = domain
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                delegate.teamDomainChanged(domain)
            }
        }
    }
    
    static func emailDomainChange(event: Event) {
        if let domain = event.emailDomain {
            Client.sharedInstance.team?.emailDomain = domain
            
            if let delegate = Client.sharedInstance.teamEventsDelegate {
                delegate.teamEmailDomainChanged(domain)
            }
        }
    }
    
    static func emojiChanged(event: Event) {
        //TODO: Call emoji.list here
        
        if let delegate = Client.sharedInstance.teamEventsDelegate {
            delegate.teamEmojiChanged()
        }
    }
    
    //Mark: - Bots
    static func bot(event: Event) {
        if let bot = event.bot {
            Client.sharedInstance.bots?[bot.id!] = bot
            
            if let delegate = Client.sharedInstance.slackEventsDelegate {
                delegate.botEvent(bot)
            }
        }
    }
    
    //MARK: - Authenticated User
    static func manualPresenceChange(event: Event) {
        Client.sharedInstance.authenticatedUser?.presence = event.presence
        
        if let delegate = Client.sharedInstance.slackEventsDelegate {
            delegate.manualPresenceChanged(Client.sharedInstance.authenticatedUser!, presence: event.presence!)
        }
    }
    
}
