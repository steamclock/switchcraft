// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Switchcraft",
    products: [
        .library(
            name: "Switchcraft",
            targets: ["Switchcraft"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Switchcraft",
            dependencies: []),
        .testTarget(
            name: "switchcraftTests",
            dependencies: ["Switchcraft"]),
    ]
)
