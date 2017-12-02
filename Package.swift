// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FreshPlanAPI",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/vapor/jwt-provider.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/validation.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", .upToNextMajor(from: "2.2.1"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider", "PostgreSQLProvider", "JWTProvider", "Validation", "SendGridProvider"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

