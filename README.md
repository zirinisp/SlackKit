![SlackKit](https://cloud.githubusercontent.com/assets/8311605/10260893/5ec60f96-694e-11e5-91fd-da6845942201.png)
##iOS/OS X Slack Client Library
###Description
This is a Slack client library for iOS and OS X written in Swift. It's intended to expose all of the functionality of Slack's [Real Time Messaging API](https://api.slack.com/rtm).

###Installation
####Swift Package Manager (Swift 2.2 and up)
Add SlackKit to your Package.swift

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/pvzig/SlackKit.git", majorVersion: 0)
    ]
)
```

Run `swift-build` on your application’s main directory.

####CocoaPods
Add the pod to your podfile:
```
pod 'SlackKit'
```
and run
```
pod install
```

To use the library in your project import it:
```
import SlackKit
```

###Usage
To use SlackKit you'll need a bearer token which identifies a single user. You can generate a [full access token or create one using OAuth 2](https://api.slack.com/web).

Once you have a token, give it to the Client:
```swift
Client.sharedInstance.setAuthToken("YOUR_SLACK_AUTH_TOKEN")
```
and connect:
```swift
Client.sharedInstance.connect()
```
Once connected, the client will begin to consume any messages sent by the Slack RTM API.

####Delegate methods
There are a number of delegates that you can set to receive callbacks for certain events.

#####SlackEventsDelegate
```swift
func clientConnected()
func clientDisconnected()
func preferenceChanged(preference: String, value: AnyObject)
func userChanged(user: User)
func presenceChanged(user: User?, presence: String?)
func manualPresenceChanged(user: User?, presence: String?)
func botEvent(bot: Bot)
```

#####MessageEventsDelegate
```swift
func messageSent(message: Message)
func messageReceived(message: Message)
func messageChanged(message: Message)
func messageDeleted(message: Message?)
```

#####ChannelEventsDelegate
```swift
func userTyping(channel: Channel?, user: User?)
func channelMarked(channel: Channel, timestamp: String?)
func channelCreated(channel: Channel)
func channelDeleted(channel: Channel)
func channelRenamed(channel: Channel)
func channelArchived(channel: Channel)
func channelHistoryChanged(channel: Channel)
func channelJoined(channel: Channel)
func channelLeft(channel: Channel)
```

#####DoNotDisturbEventsDelegate
```swift
doNotDisturbUpdated(dndStatus: DoNotDisturbStatus)
doNotDisturbUserUpdated(dndStatus: DoNotDisturbStatus, user: User?)
```

#####GroupEventsDelegate
```swift
func groupOpened(group: Channel)
```

#####FileEventsDelegate
```swift
func fileProcessed(file: File)
func fileMadePrivate(file: File)
func fileDeleted(file: File)
func fileCommentAdded(file: File, comment: Comment)
func fileCommentEdited(file: File, comment: Comment)
func fileCommentDeleted(file: File, comment: Comment)
```

#####PinEventsDelegate
```swift
func itemPinned(item: Item?, channel: Channel?)
func itemUnpinned(item: Item?, channel: Channel?)
```

#####StarEventsDelegate
```swift
func itemStarred(item: Item, star: Bool)
```

#####ReactionEventsDelegate
```swift
func reactionAdded(reaction: String?, item: Item?)
func reactionRemoved(reaction: String?, item: Item?)
```

#####TeamEventsDelegate
```swift
func teamJoined(user: User)
func teamPlanChanged(plan: String)
func teamPreferencesChanged(preference: String, value: AnyObject)
func teamNameChanged(name: String)
func teamDomainChanged(domain: String)
func teamEmailDomainChanged(domain: String)
func teamEmojiChanged()
```

#####SubteamEventsDelegate
```swift
func subteamEvent(userGroup: UserGroup)
func subteamSelfAdded(subteamID: String)
func subteamSelfRemoved(subteamID: String)
```

###Examples
####Sending a Message:
```swift
Client.sharedInstance.sendMessage(message: "Hello, world!", channelID: "CHANNEL_ID")
```

####Print a List of Users in a Channel:
```swift
let users = Client.sharedInstance.channels?["CHANNEL_ID"]?.members
print(users)
```

###Get In Touch
[@pvzig](https://twitter.com/pvzig)

<peter@launchsoft.co>
