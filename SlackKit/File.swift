//
// File.swift
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

public struct File {
    
    let id: String?
    let created: String?
    let timeStamp: String?
    let name: String?
    let title: String?
    let mimeType: String?
    let fileType: String?
    let prettyType: String?
    let user: String?
    let mode: String?
    let editable: Bool?
    let isExternal: Bool?
    let externalType: String?
    let size: Int?
    let url: String?
    let urlDownload: String?
    let urlPrivate: String?
    let urlPrivateDownload: String?
    let thumb64: String?
    let thumb80: String?
    let thumb360: String?
    let thumb360gif: String?
    let thumb360w: String?
    let thumb360h: String?
    let permalink: String?
    let editLink: String?
    let preview: String?
    let previewHighlight: String?
    let lines: Int?
    let linesMore: Int?
    internal(set) public var isPublic: Bool?
    let publicSharedURL: Bool?
    let channels: [String]?
    let groups: [String]?
    let dms: [String]?
    let initialComment: Comment?
    let stars: Int?
    let isStarred: Bool?
    let pinnedTo: [String]?
    internal(set) public lazy var comments = [Comment]?()
    
    init?(file:Dictionary<String, AnyObject>?) {
        id = file?["id"] as? String
        created = file?["created"] as? String
        timeStamp = file?["timestamp"] as? String
        name = file?["name"] as? String
        title = file?["title"] as? String
        mimeType = file?["mimetype"] as? String
        fileType = file?["filetype"] as? String
        prettyType = file?["pretty_type"] as? String
        user = file?["user"] as? String
        mode = file?["mode"] as? String
        editable = file?["editable"] as? Bool
        isExternal = file?["is_external"] as? Bool
        externalType = file?["external_type"] as? String
        size = file?["size"] as? Int
        url = file?["url"] as? String
        urlDownload = file?["url_download"] as? String
        urlPrivate = file?["url_private"] as? String
        urlPrivateDownload = file?["url_private_download"] as? String
        thumb64 = file?["thumb_64"] as? String
        thumb80 = file?["thumb_80"] as? String
        thumb360 = file?["thumb_360"] as? String
        thumb360gif = file?["thumb_360_gif"] as? String
        thumb360w = file?["thumb_360_w"] as? String
        thumb360h = file?["thumb_360_h"] as? String
        permalink = file?["permalink"] as? String
        editLink = file?["edit_link"] as? String
        preview = file?["preview"] as? String
        previewHighlight = file?["preview_highlight"] as? String
        lines = file?["lines"] as? Int
        linesMore = file?["lines_more"] as? Int
        isPublic = file?["is_public"] as? Bool
        publicSharedURL = file?["public_url_shared"] as? Bool
        channels = file?["channels"] as? [String]
        groups = file?["groups"] as? [String]
        dms = file?["ims"] as? [String]
        initialComment = Comment(comment: file?["initial_comment"] as? Dictionary<String, AnyObject>)
        stars = file?["stars"] as? Int
        isStarred = file?["is_starred"] as? Bool
        pinnedTo = file?["pinned_to"] as? [String]
    }
    
    init?(id:String?) {
        self.id = id
        created = nil
        timeStamp = nil
        name = nil
        title = nil
        mimeType = nil
        fileType = nil
        prettyType = nil
        user = nil
        mode = nil
        editable = nil
        isExternal = nil
        externalType = nil
        size = nil
        url = nil
        urlDownload = nil
        urlPrivate = nil
        urlPrivateDownload = nil
        thumb64 = nil
        thumb80 = nil
        thumb360 = nil
        thumb360gif = nil
        thumb360w = nil
        thumb360h = nil
        permalink = nil
        editLink = nil
        preview = nil
        previewHighlight = nil
        lines = nil
        linesMore = nil
        publicSharedURL = nil
        channels = nil
        groups = nil
        dms = nil
        initialComment = nil
        stars = nil
        isStarred = nil
        pinnedTo = nil
    }
}

extension File: Equatable {}

public func ==(lhs: File, rhs: File) -> Bool {
    return lhs.id == rhs.id
}
    