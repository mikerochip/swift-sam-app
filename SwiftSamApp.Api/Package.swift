// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftSamApp",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "SwiftSamApp", targets: ["SwiftSamApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "SwiftSamApp", dependencies: [
            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
            .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
        ]),
        .testTarget(name: "SwiftSamAppTests", dependencies: [
            "SwiftSamApp"
        ]),
    ]
)
