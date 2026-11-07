// swift-tools-version: 6.0
import PackageDescription

// StreetPatchKit: everything in StreetPatch that does not draw pixels. Its networking
// layer is the one built for Verdant in Chapters 17 to 20, copied and extended with
// request headers and binary bodies.
let package = Package(
    name: "StreetPatchKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "StreetPatchKit", targets: ["StreetPatchKit"])
    ],
    targets: [
        .target(name: "StreetPatchKit"),
        .testTarget(name: "StreetPatchKitTests", dependencies: ["StreetPatchKit"]),
    ]
)
