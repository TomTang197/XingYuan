// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "XingYuan",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "XingYuan",
            targets: ["XingYuan"]
        )
    ],
    targets: [
        .executableTarget(
            name: "XingYuan",
            path: "Sources/XingYuan",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "XingYuanTests",
            dependencies: ["XingYuan"],
            path: "Tests/XingYuanTests"
        )
    ]
)
