// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-shared-manuals",
  products: [
    .library(name: "AuthClient", targets: ["AuthClient"]),
    .library(name: "SharedDatabase", targets: ["SharedDatabase"]),
    .library(name: "SharedMiddleware", targets: ["SharedMiddleware"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
    .library(name: "SharedTestSupport", targets: ["SharedTestSupport"]),
    .library(name: "SharedStyleguide", targets: ["SharedStyleguide"]),
    .library(name: "SharedViews", targets: ["SharedViews"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0"),
    .package(url: "https://github.com/m-housh/swift-validations.git", from: "0.3.5"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
    .package(url: "https://github.com/pointfreeco/vapor-routing.git", from: "0.1.3"),
    .package(url: "https://github.com/elementary-swift/elementary.git", from: "0.6.0"),
    .package(url: "https://github.com/elementary-swift/elementary-htmx.git", from: "0.5.0"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
  ],
  targets: [
    .target(
      name: "AuthClient",
      dependencies: [
        .target(name: "SharedDatabase"),
        .product(name: "Vapor", package: "vapor"),
      ]
    ),
    .target(
      name: "SharedMiddleware",
      dependencies: [
        .target(name: "AuthClient"),
        .target(name: "SharedDatabase"),
        .target(name: "SharedViews"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "VaporRouting", package: "vapor-routing"),
      ]
    ),
    .testTarget(
      name: "SharedMiddlewareTests",
      dependencies: [
        .target(name: "SharedMiddleware"),
        .target(name: "SharedTestSupport"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "VaporTesting", package: "vapor"),
      ]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "URLRouting", package: "swift-url-routing"),
        .product(name: "Vapor", package: "vapor"),
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
        .target(name: "SharedTestSupport"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      ]
    ),
    .target(
      name: "SharedTestSupport",
      dependencies: [
        .target(name: "AuthClient"),
        .target(name: "SharedMiddleware"),
        .target(name: "SharedDatabase"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "VaporTesting", package: "vapor"),
      ]
    ),
    .target(
      name: "SharedStyleguide",
      dependencies: [
        .target(name: "SharedModels"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Elementary", package: "elementary"),
        .product(name: "ElementaryHTMX", package: "elementary-htmx"),
        .product(name: "Validations", package: "swift-validations"),
      ]
    ),
    .testTarget(
      name: "SharedViewTests",
      dependencies: [
        .target(name: "SharedStyleguide"),
        .target(name: "SharedTestSupport"),
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
      ],
      resources: [
        .copy("__Snapshots__")
      ],
    ),
    .testTarget(
      name: "SharedRouteTests",
      dependencies: [
        .target(name: "SharedModels")
      ]
    ),
    .target(
      name: "SharedViews",
      dependencies: [
        .target(name: "AuthClient"),
        .target(name: "SharedDatabase"),
        .target(name: "SharedModels"),
        .target(name: "SharedStyleguide"),
      ]
    ),
  ]
)
