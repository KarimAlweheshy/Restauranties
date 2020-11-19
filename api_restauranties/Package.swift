// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "api_restauranties",
    platforms: [
        .macOS(.v10_14)
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.2.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "5.0.0-alpha.4")
    ],
    targets: [
        .target(
            name: "api_restauranties",
            dependencies: [
                .product(name: "SotoDynamoDB", package: "soto"),
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime")
            ]),
        .testTarget(
            name: "api_restaurantiesTests",
            dependencies: ["api_restauranties"]),
    ]
)
