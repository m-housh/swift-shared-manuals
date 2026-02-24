// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "dev-server",
  dependencies: [
    .package(path: "../"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
  ],
  targets: [
    .executableTarget(
      name: "dev-server",
      dependencies: [
        .product(name: "UserViewController", package: "swift-shared-manuals"),
        .product(name: "SharedDatabase", package: "swift-shared-manuals"),
        .product(name: "SharedMiddleware", package: "swift-shared-manuals"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      ]
    )
  ]
)
