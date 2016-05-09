import PackageDescription

let package = Package(
    name: "robot-or-not-bot",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/pvzig/SlackKit.git", majorVersion: 0, minor: 0),
    ]
)
