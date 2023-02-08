// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceryPlugin",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .plugin(name: "SourceryPlugin", targets: ["SourceryPlugin"]),
    ],
    dependencies: [
    ],
    targets: [
        .plugin(name: "SourceryPlugin", capability: .buildTool(), dependencies: ["sourcery"]),
        .binaryTarget(name: "sourcery", path: "./sourcery.artifactbundle.zip"),
    ]
)
