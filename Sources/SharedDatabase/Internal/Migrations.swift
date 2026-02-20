import Dependencies
import Fluent
import SharedModels

extension SharedDatabase.Migrations: DependencyKey {
  public static let testValue = Self()

  public static let liveValue = Self(
    allMigrations: {
      [
        // Must create user table first, as other models rely on it's foreign keys.
        User.Migrate(),
        User.Profile.Migrate(),
        User.Token.Migrate(),
        Project.Migrate()
      ]
    }
  )
}
