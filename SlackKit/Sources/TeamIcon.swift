//
//  TeamIcon.swift
//  Pods
//
//  Created by 佑介 村田 on 2016/02/27.
//
//

public struct TeamIcon {
    internal(set) public var image34: String?
    internal(set) public var image44: String?
    internal(set) public var image68: String?
    internal(set) public var image88: String?
    internal(set) public var image102: String?
    internal(set) public var image132: String?
    internal(set) public var imageOriginal: String?
    internal(set) public var imageDefault: Bool?

    internal init?(icon: [String: AnyObject]?) {
        image34 = icon?["image_34"] as? String
        image44 = icon?["image_44"] as? String
        image68 = icon?["image_68"] as? String
        image88 = icon?["image_88"] as? String
        image102 = icon?["image_102"] as? String
        image132 = icon?["image_132"] as? String
        imageOriginal = icon?["image_original"] as? String
        imageDefault = icon?["image_default"] as? Bool
    }
}
