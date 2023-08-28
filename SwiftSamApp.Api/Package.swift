// swift-tools-version:5.7

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
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", branch: "main"),
    ],
    targets: [
        .target(name: "SwiftSamApp", dependencies: [
            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
            .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
        ]),
        .testTarget(name: "SwiftSamAppTests", dependencies: [
            "SwiftSamApp"
        ]),
    ]
)
