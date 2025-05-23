// swift-tools-version:5.8.0

import PackageDescription

let package = Package(
    name: "SwiftSamApp",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "SwiftSamApp", targets: ["SwiftSamApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.3"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(name: "SwiftSamApp", dependencies: [
            .product(name: "HTTPTypes", package: "swift-http-types"),
            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
            .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
        ]),
        .testTarget(name: "SwiftSamAppTests", dependencies: [
            "SwiftSamApp"
        ]),
    ]
)
