// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClearSpend",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ClearSpend",
            targets: ["ClearSpend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/algorand/swift-algorand-sdk.git", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "ClearSpend",
            dependencies: [
                .product(name: "AlgorandSDK", package: "swift-algorand-sdk")
            ]),
        .testTarget(
            name: "ClearSpendTests",
            dependencies: ["ClearSpend"]),
    ]
)