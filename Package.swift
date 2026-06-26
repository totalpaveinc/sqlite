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
            url: "https://github.com/totalpaveinc/sqlite/releases/download/v0.4.1/sqlite.xcframework.zip",
            checksum: "e6333a364e3d6454f3329f69dbea71fdc3f71fca099c9ff22f23f42834443029"
        )
    ]
)
