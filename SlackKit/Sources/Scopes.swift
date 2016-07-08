//
//  Scope.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/5/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

enum Scope {
    
    enum API {
        enum Channels: String {
            case History = "channels:history"
            case Read = "channels:read"
            case Write = "channels:write"
        }
        
        enum Chat: String {
            case WriteBot = "chat:write:bot"
            case WriteUser = "chat:write:user"
        }
        
        enum DND: String {
            case Read = "dnd:read"
            case Write = "dnd:write"
        }
        
        enum Emoji: String {
            case Read = "emoji:read"
        }
        
        enum Files: String {
            case Read = "files:read"
            case WriteUser = "files:write:user"
        }
        
        enum Groups: String {
            case History = "groups:history"
            case Read = "groups:read"
            case Write = "groups:write"
            
        }
        
        enum Identity: String {
            case Basic = "identity.basic"
        }
        
        enum IM: String {
            case History = "im:history"
            case Read = "im:read"
            case Write = "im:write"
        }
        
        enum MPIM: String {
            case History = "mpim:history"
            case Read = "mpim:read"
            case Write = "mpim:write"
        }
        
        enum Pins: String {
            case Read = "pins:read"
            case Write = "pins:write"
        }
        
        enum Reactions: String {
            case Read = "reactions:read"
            case Write = "reactions:write"
        }
        
        enum Reminders: String {
            case Read = "reminders:read"
            case Write = "reminders:write"
        }
        
        enum Search: String {
            case Read = "search:read"
        }
        
        enum Stars: String {
            case Read = "stars:read"
            case Write = "stars:write"
        }
        
        enum Team: String {
            case Read = "team:read"
        }
        
        enum UserGroups: String {
            case Read = "usergroups:read"
            case Write = "usergroups:write"
        }
        
        enum UserProfiles: String {
            case Read = "user.profiles:read"
            case Write = "user.profiles:write"
        }
        
        enum Users: String {
            case Read = "users:read"
            case Write = "users:write"
        }
    }
    
    enum SlackApp: String {
        case IncomingWebhook = "incoming-webhook"
        case Commands = "commands"
        case Bot = "bot"
    }
    
    enum Special: String {
        case Identify = "identify"
        case Client = "client"
        case Admin = "admin"
    }
    
    enum Deprecated: String {
        case Read = "read"
        case Post = "post"
    }

}