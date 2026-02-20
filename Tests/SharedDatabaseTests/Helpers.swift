import Dependencies
import Fluent
import FluentSQLiteDriver
import SharedDatabase
import SharedModels
import Vapor

extension DependencyValues {
  var database: SharedDatabase {
    get { self[SharedDatabase.self] }
    set { self[SharedDatabase.self] = newValue }
  }
}

func withDatabase(
  setupDependencies: @escaping (inout DependencyValues) async throws -> Void = { _ in },
  operation: @escaping () async throws -> Void
) async throws {
  let app = try await Application.make(.testing)
  app.databases.use(DatabaseConfigurationFactory.sqlite(.memory), as: .sqlite)
  do {
    let database = app.db
    let sharedDB = SharedDatabase.live(on: database)
    try await app.migrations.add(sharedDB.migrations())
    try await app.autoMigrate()

    try await withDependencies {
      $0.uuid = .incrementing
      $0.database = sharedDB
      try await setupDependencies(&$0)
    } operation: {
      try await operation()
    }

    try await app.autoRevert()
    try await app.asyncShutdown()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }

}

/// Set's up the database and a test user for running tests that require a
/// a user.
func withTestUser(
  setupDependencies: @escaping (inout DependencyValues) -> Void = { _ in },
  operation: @escaping (User) async throws -> Void
) async throws {
  try await withDatabase(setupDependencies: setupDependencies) {
    @Dependency(\.database.users) var users
    let user = try await users.create(
      .init(email: "testy@example.com", password: "super-secret", confirmPassword: "super-secret")
    )
    try await operation(user)
  }
}
