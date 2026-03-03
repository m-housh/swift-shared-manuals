import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
@preconcurrency import URLRouting
import Vapor

// configures your application
public func configure(
  _ app: Application
) async throws {
  let db = try await setupDatabase(on: app)
  addMiddleware(to: app, database: db)
  addRoutes(to: app)
  try await app.autoMigrate()
}

private func setupDatabase(
  on app: Application
) async throws -> SharedDatabase {
  let dbFile = Environment.get("SQLITE_FILE") ?? "db.sqlite"
  app.databases.use(.sqlite(.file(dbFile)), as: .sqlite)
  let sharedDB = SharedDatabase.live(on: app.db)
  try await app.migrations.add(sharedDB.migrations())
  return sharedDB
}

private func addMiddleware(
  to app: Application,
  database: SharedDatabase,
) {
  // cors middleware should come before default error middleware using `at: .beginning`
  let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin,
      .xRequestedWith, .userAgent, .accessControlAllowOrigin,
    ]
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  app.middleware.use(cors, at: .beginning)
  // File middleware.
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  // Sessions.
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
  app.middleware.use(app.sessions.middleware)
  // Dependencies
  app.middleware.use(
    DependenciesMiddleware { dependencies, request in
      dependencies.sharedDatabase = database
      dependencies.auth = .live(on: request)
      dependencies.document = .live(title: "Dev Server")
      dependencies.logger = request.logger
    }
  )
}

func addRoutes(
  to app: Application
) {
  app.mount(
    controller: SiteViewController(),
    routeMiddleware: { route in
      switch route {
      case .shared(.auth(.login)),
        .shared(.user(.signup)),
        .shared(.privacyPolicy):
        return nil
      case .home,
        .shared(.user(.profile)),
        .shared(.auth(.logout)),
        .shared(.project):
        return [
          User.passwordAuth(),
          User.sessionAuth(),
          User.redirectMiddleware(path: "/login"),
        ]
      }
    }
  )
}
