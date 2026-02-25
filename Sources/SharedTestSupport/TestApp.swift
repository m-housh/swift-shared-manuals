import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import SharedModels
import SharedDatabase
import SharedMiddleware
import Vapor

public func withTestAppAndDatabase(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  test runTest: @Sendable (Application, SharedDatabase) async throws -> Void,
) async throws {

  let app = try await Application.make(.testing)

  do {
    let sharedDatabase = try await setupDatabase(on: app)
    app.middleware.use(
      DependenciesMiddleware.test(
        database: sharedDatabase,
        setupDependencies: setupDependencies
      )
    )
    try await app.autoMigrate()
    try await runTest(app, sharedDatabase)
    try await app.autoRevert()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }

  try await app.asyncShutdown()
}

public func withTestApp(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  test runTest: @Sendable (Application) async throws -> Void
) async throws {
  try await withTestAppAndDatabase(setupDependencies: setupDependencies) { app, _ in
    try await runTest(app)
  }
}

public func withTestDatabase(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  test runTest: @Sendable () async throws -> Void
) async throws {
  try await withTestAppAndDatabase(setupDependencies: setupDependencies) { _, db in
    try await withDependencies {
      $0.sharedDatabase = db
      setupDependencies(&$0)
    } operation: {
      try await runTest()
    }
  }
}
private func setupDatabase(on app: Application) async throws -> SharedDatabase {
  app.databases.use(.sqlite(.memory), as: .sqlite)
  let database = SharedDatabase.live(on: app.db)
  try await app.migrations.add(database.migrations())
  return database
}

extension DependenciesMiddleware {

  public static func test(
    auth authClient: AuthClient? = nil,
    database sharedDatabase: SharedDatabase,
    logger: Logger = .init(label: "test"),
    setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in }
  ) -> Self {
    .init { dependencies, request in
      dependencies.auth = authClient ?? .live(on: request)
      dependencies.sharedDatabase = sharedDatabase
      dependencies.logger = logger
      setupDependencies(&dependencies)
    }
  }

}
