//
//  AppDelegate.swift
//  OSX-Sample
//
//  Created by Peter Zignego on 2/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Cocoa
import SlackKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SlackEventsDelegate {

    @IBOutlet weak var window: NSWindow!

    let client = Client(apiToken: "")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        client.connect()
        client.slackEventsDelegate = self
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func clientConnected() {
        
    }
    
    func clientDisconnected() {}
    func preferenceChanged(preference: String, value: AnyObject) {}
    func userChanged(user: User) {}
    func presenceChanged(user: User?, presence: String?) {}
    func manualPresenceChanged(user: User?, presence: String?) {}
    func botEvent(bot: Bot) {}

}

