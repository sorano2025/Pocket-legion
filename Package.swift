// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PocketLegion",
    platforms: [.iOS(.v17)],
    products: [
        .executable(name: "PocketLegion", targets: ["PocketLegion"])
    ],
    targets: [
        .executableTarget(
            name: "PocketLegion",
            path: "Sources",
            resources: [.process("Resources")]
        )
    ]
)
