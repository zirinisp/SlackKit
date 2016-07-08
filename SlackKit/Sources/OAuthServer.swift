//
//  OAuthServer.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/6/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation
import Swifter

struct OAuthServer {
    
    let http = HttpServer()
    
    init() {
        http["/oauth"] = { request in
            print(request)
            return .OK(.Text("Ok."))
        }
    }
}