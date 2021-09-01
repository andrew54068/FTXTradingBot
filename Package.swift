// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "FTXTradingBot",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1"),
        .package(url: "https://github.com/Moya/Moya.git", from: "14.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Jobs", package: "Jobs"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
