// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TaskTimerApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TaskTimerApp",
            targets: ["TaskTimerApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TaskTimerApp",
            dependencies: [],
                    )
    ]
)