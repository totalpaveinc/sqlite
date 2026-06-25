// swift-tools-version:5.7
//
// SQLite built for iOS and iOS simulators.
//
// This file is generated from Package.swift.template by build.sh.
// Do not edit Package.swift directly; edit the template instead.
//
import PackageDescription

let package = Package(
    name: "sqlite",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "sqlite",
            targets: ["sqlite"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "sqlite",
            url: "https://github.com/totalpaveinc/sqlite/releases/download/v0.4.0/sqlite.xcframework.zip",
            checksum: "06d194a9af008c8710372711af46f6f09a3ba08da708e3dc94b50126ff081d17"
        )
    ]
)
