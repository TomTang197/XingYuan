// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "YouShu",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "YouShu",
            targets: ["YouShu"]
        )
    ],
    targets: [
        .executableTarget(
            name: "YouShu",
            path: "Sources/YouShu"
        ),
        .testTarget(
            name: "YouShuTests",
            dependencies: ["YouShu"],
            path: "Tests/YouShuTests"
        )
    ]
)
