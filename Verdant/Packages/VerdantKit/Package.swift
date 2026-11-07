// swift-tools-version: 6.0
import PackageDescription

// VerdantKit holds everything in Verdant that does not draw pixels: models, care
// rules, view models, persistence, networking. It builds and is tested on iOS,
// macOS and Linux.
let package = Package(
    name: "VerdantKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "VerdantKit", targets: ["VerdantKit"])
    ],
    targets: [
        .target(name: "VerdantKit"),
        .testTarget(name: "VerdantKitTests", dependencies: ["VerdantKit"]),
    ]
)
