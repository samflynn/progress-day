// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProgressDay",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ProgressDay",
            path: "ProgressDay",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "ProgressDay/Info.plist"
                ])
            ]
        )
    ]
)
