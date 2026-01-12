// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BudgetApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BudgetApp",
            targets: ["BudgetApp"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BudgetApp",
            dependencies: [],
            path: "BudgetApp"
        ),
        .testTarget(
            name: "BudgetAppTests",
            dependencies: ["BudgetApp"],
            path: "BudgetAppTests"
        ),
    ]
)
