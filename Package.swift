// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesktopOrganizer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "DesktopOrganizer",
            targets: ["DesktopOrganizer"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DesktopOrganizer",
            dependencies: [],
            path: "DesktopOrganizer",
            exclude: ["Resources/Info.plist", "Resources/DesktopOrganizer.entitlements"]
        )
    ]
)
