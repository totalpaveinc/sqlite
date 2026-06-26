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
            url: "https://github.com/totalpaveinc/sqlite/releases/download/v0.4.5/sqlite.xcframework.zip",
            checksum: "91771cb6dc395869aaf6a847ec35cd64e8074f20bb3ab4acc268a4991e491aba"
        )
    ]
)
