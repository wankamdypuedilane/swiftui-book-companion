// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GardenKit",
    products: [
        .library(name: "GardenKit", targets: ["GardenKit"]),
    ],
    targets: [
        .target(name: "GardenKit"),
        .executableTarget(name: "garden-report", dependencies: ["GardenKit"]),
        .testTarget(name: "GardenKitTests", dependencies: ["GardenKit"]),
    ]
)
