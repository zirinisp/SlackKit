![SlackKit](https://cloud.githubusercontent.com/assets/8311605/10260893/5ec60f96-694e-11e5-91fd-da6845942201.png)
##iOS/OS X Slack Client Library
###Description
This is a Slack client library for iOS and OS X written in Swift. It's intended to expose all of the functionality of Slack's [Real Time Messaging API](https://api.slack.com/rtm).

###Installation
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
