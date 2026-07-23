// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "EighToBadgeCore",
  platforms: [
    .iOS(.v26),
    .watchOS(.v26),
  ],
  products: [
    .library(name: "EighToBadgeCore", targets: ["EighToBadgeCore"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "EighToBadgeCore",
      dependencies: [],
      path: "Sources/EighToBadgeCore",
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
    .testTarget(
      name: "EighToBadgeCoreTests",
      dependencies: ["EighToBadgeCore"],
      path: "Tests/EighToBadgeCoreTests"
    ),
  ]
)
