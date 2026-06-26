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
            url: "https://github.com/totalpaveinc/sqlite/releases/download/v0.4.2/sqlite.xcframework.zip",
            checksum: "4d11867b36da2ab803ca52c8764793b1fd30060dfe654b9e7fed242886bf4bfa"
        )
    ]
)
