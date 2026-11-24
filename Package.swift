// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OutputSwitcher",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(name: "OutputSwitcher"),
        .testTarget(name: "OutputSwitcherTests", dependencies: ["OutputSwitcher"]),
    ]
)
