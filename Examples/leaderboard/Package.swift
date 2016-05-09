import PackageDescription

let package = Package(
    name: "leaderboard",
    dependencies: [
        .Package(url: "https://github.com/pvzig/SlackKit.git", majorVersion: 0, minor: 0),
    ]
)
