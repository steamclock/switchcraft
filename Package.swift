// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "switchcraft",
    products: [
        .library(
            name: "switchcraft",
            targets: ["switchcraft"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "switchcraft",
            dependencies: []),
        .testTarget(
            name: "switchcraftTests",
            dependencies: ["switchcraft"]),
    ]
)
