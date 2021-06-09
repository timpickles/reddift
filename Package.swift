// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Reddift",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v10),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Reddift",
            targets: ["Reddift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sonsongithub/HTMLSpecialCharacters.git", .upToNextMajor(from: "1.4.0")),
        .package(url: "https://github.com/timpickles/MiniKeychain.git", .upToNextMajor(from: "1.0.9")),
    ],
    targets: [
        .target(
            name: "Reddift",
            dependencies: ["HTMLSpecialCharacters", "MiniKeychain"],
            path: "framework"
        ),
        .testTarget(
            name: "ReddiftTests",
            dependencies: ["Reddift"],
            path: "test"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
