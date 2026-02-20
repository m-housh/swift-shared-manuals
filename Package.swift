// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-shared-manuals",
  products: [
    .library(name: "AuthClient", targets: ["AuthClient"]),
    .library(name: "SharedMiddleware", targets: ["SharedMiddleware"]),
    .library(name: "LoggingDependency", targets: ["LoggingDependency"]),
    .library(name: "SharedDatabase", targets: ["SharedDatabase"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
    .package(url: "https://github.com/pointfreeco/vapor-routing.git", from: "0.1.3"),
    .package(url: "https://github.com/m-housh/swift-validations.git", from: "0.3.5"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
  ],
  targets: [
    .target(
      name: "AuthClient",
      dependencies: [
        .target(name: "LoggingDependency"),
        .target(name: "SharedDatabase"),
        .product(name: "Vapor", package: "vapor"),
      ]
    ),
    .target(
      name: "SharedMiddleware",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "VaporRouting", package: "vapor-routing"),
      ]
    ),
    .testTarget(
      name: "SharedMiddlewareTests",
      dependencies: [
        .target(name: "AuthClient"),
        .target(name: "SharedMiddleware"),
        .target(name: "SharedDatabase"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "VaporTesting", package: "vapor"),
      ]
    ),
    .target(
      name: "LoggingDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
      ]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ],
    ),
    .target(
      name: "SharedDatabase",
      dependencies: [
        .target(name: "SharedModels"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Validations", package: "swift-validations"),
      ]
    ),
    .testTarget(
      name: "SharedDatabaseTests",
      dependencies: [
        .target(name: "SharedDatabase"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      ]
    ),
  ]
)
