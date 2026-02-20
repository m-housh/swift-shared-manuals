import Dependencies
import DependenciesMacros
import Fluent
import SharedModels

extension DependencyValues {
  public var sharedDatabase: SharedDatabase {
    get { self[SharedDatabase.self] }
    set { self[SharedDatabase.self] = newValue }
  }
}

public struct SharedDatabase: Sendable {

  public var migrations: Migrations
  public var projects: Projects
  public var users: Users
  public var userProfiles: UserProfiles

  @DependencyClient
  public struct Migrations: Sendable {
    public var allMigrations: @Sendable () async throws -> [any AsyncMigration]

    public func callAsFunction() async throws -> [any AsyncMigration] {
      try await self.allMigrations()
    }
  }

  @DependencyClient
  public struct Projects: Sendable {
    public var create: @Sendable (User.ID, Project.Create) async throws -> Project
    public var delete: @Sendable (Project.ID) async throws -> Void
    public var get: @Sendable (Project.ID) async throws -> Project?
    public var fetch: @Sendable (User.ID, PageRequest) async throws -> Page<Project>
    public var update: @Sendable (Project.ID, Project.Update) async throws -> Project
  }

  @DependencyClient
  public struct Users: Sendable {
    public var create: @Sendable (User.Create) async throws -> User
    public var delete: @Sendable (User.ID) async throws -> Void
    public var get: @Sendable (User.ID) async throws -> User?
    public var login: @Sendable (User.Login) async throws -> User.Token
    public var logout: @Sendable (User.Token.ID) async throws -> Void
  }

  @DependencyClient
  public struct UserProfiles: Sendable {
    public var create: @Sendable (User.Profile.Create) async throws -> User.Profile
    public var delete: @Sendable (User.Profile.ID) async throws -> Void
    public var fetch: @Sendable (User.ID) async throws -> User.Profile?
    public var get: @Sendable (User.Profile.ID) async throws -> User.Profile?
    public var update: @Sendable (User.Profile.ID, User.Profile.Update) async throws -> User.Profile
  }

}

extension SharedDatabase: TestDependencyKey {
  public static let testValue = Self(
    migrations: .testValue,
    projects: .testValue,
    users: .testValue,
    userProfiles: .testValue
  )

  public static func live(on database: any Database) -> Self {
    .init(
      migrations: .liveValue,
      projects: .live(database: database),
      users: .live(database: database),
      userProfiles: .live(database: database)
    )
  }
}
