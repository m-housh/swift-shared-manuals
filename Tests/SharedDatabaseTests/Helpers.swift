import Dependencies
import Fluent
import FluentSQLiteDriver
import SharedDatabase
import SharedModels
import SharedTestSupport
import Vapor

/// Set's up the database and a test user for running tests that require a
/// a user.
func withTestUser(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  operation: @escaping @Sendable (User) async throws -> Void
) async throws {
  try await withTestDatabase(setupDependencies: setupDependencies) {
    @Dependency(\.sharedDatabase.users) var users
    let user = try await users.create(
      .init(email: "testy@example.com", password: "super-secret", confirmPassword: "super-secret")
    )
    try await operation(user)
  }
}
