// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParticialSheet",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ParticialSheet", targets: ["ParticialSheet"]),
    ],
    dependencies: [
        .package(name: "FittedSheets", url: "https://github.com/gordontucker/FittedSheets", ._exactItem("2.4.1"))
    ],
    targets: [
        .target(name: "ParticialSheet", dependencies: ["FittedSheets"]),
    ]
)
