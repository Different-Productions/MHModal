// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MHModal",
  platforms: [
    .iOS(.v17),  // Updated to iOS 17 for @Observable support
    .macOS(.v14)  // Updated to macOS 14 for @Observable support
  ],
  products: [
    .library(
      name: "MHModal",
      targets: ["MHModal"])
  ],
  targets: [
    .target(
      name: "MHModal"),
    .testTarget(
      name: "MHModalTests",
      dependencies: ["MHModal"]
    )
  ]
)
