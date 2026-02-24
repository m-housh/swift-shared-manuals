import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import LoggingDependency
import SharedDatabase
import SharedMiddleware
import SharedModels
@preconcurrency import URLRouting
import UserViewController
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

  // Sessions.
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
  app.middleware.use(app.sessions.middleware)

  app.middleware.use(
    DependenciesMiddleware { dependencies, request in
      dependencies.sharedDatabase = database
      dependencies.auth = .live(on: request)
      dependencies.mainPage = MyMainPage()
      dependencies.logger = Logger(label: "com.dev-server")
    }
  )
}

func addRoutes(
  to app: Application
) {
  @Dependency(\.viewResponder) var responder
  @Dependency(\.userViewController) var viewController

  app.mount(
    UserRoute.router,
    controller: viewController
      // use: {
      //   try await responder.respond(
      //     viewController.viewResponse($0, $1)
      //   )
      // }
  )
}
