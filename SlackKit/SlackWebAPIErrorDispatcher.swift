//
//  SlackWebAPIErrorHandling.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/21/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

internal enum SlackError: ErrorType {
    case AlreadyArchived
    case AccountInactive
    case AlreadyPinned
    case AlreadyReacted
    case AlreadyStarred
    case BadTimeStamp
    case CantArchiveGeneral
    case CantDeleteFile
    case CantDeleteMessage
    case CantUpdateMessage
    case ChannelNotFound
    case ComplianceExportsPreventDeletion
    case EditWindowClosed
    case FileCommentNotFound
    case FileDeleted
    case FileNotFound
    case FileNotShared
    case InvalidArrayArg
    case InvalidAuth
    case InvalidChannel
    case InvalidName
    case InvalidPresence
    case InvalidTS
    case InvalidTSLatest
    case InvalidTSOldest
    case IsArchived
    case LastRAChannel
    case MessageNotFound
    case MessageTooLong
    case MigrationInProgress
    case NoItemSpecified
    case NoReaction
    case NoText
    case NotAuthed
    case NotEnoughUsers
    case NotInChannel
    case NotPinned
    case NotStarred
    case PermissionDenied
    case PostingToGeneralChannelDenied
    case RateLimited
    case RequestTimeout
    case RestrictedAction
    case TooLong
    case TooManyEmoji
    case TooManyReactions
    case TooManyUsers
    case UnknownError
    case UserDisabled
    case UserDoesNotOwnChannel
    case UserIsRestricted
    case UserListNotSupplied
    case UserNotFound
    case UserNotVisible
}

internal struct ErrorDispatcher {
    
    static func dispatch(error: String) -> SlackError {
        switch error {
        case "account_inactive":
            return .AccountInactive
        case "already_pinned":
            return .AlreadyPinned
        case "already_reacted":
            return .AlreadyReacted
        case "already_starred":
            return .AlreadyStarred
        case "bad_timestamp":
            return .BadTimeStamp
        case "cant_delete_file":
            return .CantDeleteFile
        case "cant_delete_message":
            return .CantDeleteMessage
        case "cant_update_message":
            return .CantUpdateMessage
        case "compliance_exports_prevent_deletion":
            return .ComplianceExportsPreventDeletion
        case "channel_not_found":
            return .ChannelNotFound
        case "edit_window_closed":
            return .EditWindowClosed
        case "file_comment_not_found":
            return .FileCommentNotFound
        case "file_deleted":
            return .FileDeleted
        case "file_not_found":
            return .FileNotFound
        case "file_not_shared":
            return .FileNotShared
        case "invalid_array_arg":
            return .InvalidArrayArg
        case "invalid_auth":
            return .InvalidAuth
        case "invalid_channel":
            return .InvalidChannel
        case "invalid_name":
            return .InvalidName
        case "invalid_presence":
            return .InvalidPresence
        case "invalid_timestamp":
            return .InvalidTS
        case "invalid_ts_latest":
            return .InvalidTSLatest
        case "invalid_ts_oldest":
            return .InvalidTSOldest
        case "is_archived":
            return .IsArchived
        case "message_not_found":
            return .MessageNotFound
        case "msg_too_long":
            return .MessageTooLong
        case "migration_in_progress":
            return .MigrationInProgress
        case "no_reaction":
            return .NoReaction
        case "no_item_specified":
            return .NoItemSpecified
        case "no_text":
            return .NoText
        case "not_authed":
            return .NotAuthed
        case "not_enough_users":
            return .NotEnoughUsers
        case "not_in_channel":
            return .NotInChannel
        case "not_pinned":
            return .NotPinned
        case "not_starred":
            return .NotStarred
        case "perimssion_denied":
            return .PermissionDenied
        case "posting_to_general_channel_denied":
            return .PostingToGeneralChannelDenied
        case "rate_limited":
            return .RateLimited
        case "request_timeout":
            return .RequestTimeout
        case "too_long":
            return .TooLong
        case "too_many_emoji":
            return .TooManyEmoji
        case "too_many_reactions":
            return .TooManyReactions
        case "too_many_users":
            return .TooManyUsers
        case "user_disabled":
            return .UserDisabled
        case "user_does_not_own_channel":
            return .UserDoesNotOwnChannel
        case "user_is_restricted":
            return .UserIsRestricted
        case "user_list_not_supplied":
            return .UserListNotSupplied
        case "user_not_found":
            return .UserNotFound
        case "user_not_visible":
            return .UserNotVisible
        default:
            return .UnknownError
        }
    }
}
