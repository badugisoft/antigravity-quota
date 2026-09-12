// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AntigravityQuota",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AntigravityQuota",
            targets: ["AntigravityQuota"]
        ),
        .executable(
            name: "AntigravityQuotaWidgetExtension",
            targets: ["AntigravityQuotaWidgetExtension"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AntigravityQuotaCore",
            dependencies: [],
            path: "Sources/AntigravityQuotaCore"
        ),
        .executableTarget(
            name: "AntigravityQuota",
            dependencies: ["AntigravityQuotaCore"],
            path: "Sources/AntigravityQuota",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "AntigravityQuotaWidgetExtension",
            dependencies: ["AntigravityQuotaCore"],
            path: "Sources/AntigravityQuotaWidget",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-e", "-Xlinker", "_NSExtensionMain"])
            ]
        ),
        .testTarget(
            name: "AntigravityQuotaTests",
            dependencies: ["AntigravityQuotaCore", "AntigravityQuota"],
            path: "Tests/AntigravityQuotaTests"
        )
    ]
)
