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
            url: "https://github.com/totalpaveinc/sqlite/releases/download/v0.4.4/sqlite.xcframework.zip",
            checksum: "8c70864fbb1fcdc9c98b893e2c143ab0e9cf95b7a0783d10535100291ba50842"
        )
    ]
)
