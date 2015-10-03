#SlackKit
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
To use SlackRTMKit you'll need a bearer token which identifies a single user. You can generate a [full access token or create one using OAuth 2](https://api.slack.com/web).

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


