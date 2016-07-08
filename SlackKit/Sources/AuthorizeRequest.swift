//
//  AuthorizeRequest.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/6/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

struct AuthorizeRequest {
    
    let clientID: String
    let scope: [Scope]
    let redirectURI: String?
    let state: String?
    let team: String?
    
    init(clientID: String, scope:[Scope], redirectURI: String? = nil, state: String? = nil, team: String? = nil) {
        self.clientID = clientID
        self.scope = scope
        self.redirectURI = redirectURI
        self.state = state
        self.team = team
    }
}