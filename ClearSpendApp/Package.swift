// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClearSpendApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ClearSpendApp", targets: ["ClearSpendApp"])
    ],
    dependencies: [],
    targets: [
        .target(name: "ClearSpendApp", dependencies: [])
    ]
)