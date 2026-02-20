import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import LoggingDependency
import SharedDatabase
import SharedModels
import Testing
@preconcurrency import URLRouting
import Vapor
import VaporRouting
import VaporTesting

@testable import SharedMiddleware

// FIX: Add authenticated routes to test suite.
@Suite("SharedMiddlewareTests", .serialized)
struct MiddlewareTests {

  @Test
  func sanity() {
    #expect(Bool(true))
  }

  @Test
  func integrationTest() async throws {

    let newUser = User.Create(
      email: "testy@example.com",
      password: "super-secret",
      confirmPassword: "super-secret"
    )

    try await withAppIncludingDB { app in

      try await app.testing().test(
        .POST, "users",
        beforeRequest: { req in
          try req.content.encode(newUser)
        },
        afterResponse: { res in
          #expect(res.status == .ok)
          let user = try res.content.decode(User.self)
          #expect(user.email == newUser.email)

          // try await app.testing().test(.GET, "home") { res in
          //   #expect(res.status == .ok)
          // }
        })

    }
  }

  @Test
  func notFoundRoute() async throws {
    try await withAppIncludingDB { app in
      try await app.testing().test(.GET, "users") { res in
        #expect(res.status == .notFound)
      }
      try await app.testing().test(.GET, "home") { res in
        #expect(res.status == .unauthorized)
      }
    }
  }
}

func configure(_ app: Application) async throws {

  app.databases.use(.sqlite(.memory), as: .sqlite)

  let sharedDatabase = SharedDatabase.live(on: app.db)
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
  try await app.migrations.add(sharedDatabase.migrations())
  try await app.autoMigrate()

  app.middleware.use(app.sessions.middleware)

  app.middleware.use(
    DependenciesMiddleware { dependencies, request in
      dependencies.sharedDatabase = sharedDatabase
      dependencies.auth = withDependencies {
        $0.sharedDatabase = sharedDatabase
        $0.logger = Logger(label: "com.test.logger")
      } operation: {
        AuthClient.live(on: request)
      }
    }
  )

  app.mount(
    TestRoute.router,
    middleware: { route in
      switch route {
      case .createUser:
        return nil
      case .loggedIn:
        return [
          UserPasswordAuthenticator(),
          UserSessionAuthenticator(),
          User.guardMiddleware(),
        ]
      }
    },
    use: siteHandler
  )
}

enum TestRoute: Sendable {
  case createUser(User.Create)
  case loggedIn

  static let router = OneOf {
    Route(.case(TestRoute.createUser)) {
      Path { "users" }
      Method.post
      Body(.json(User.Create.self))
    }
    Route(.case(Self.loggedIn)) {
      Path { "home" }
      Method.get
    }
  }
}

@Sendable
private func siteHandler(
  _ request: Request,
  _ route: TestRoute
) async throws -> any AsyncResponseEncodable {
  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database

  switch route {
  case .createUser(let user):
    return try await auth.createAndLogin(user)
  case .loggedIn:
    return "Hello, world!"
  }
}
extension User.Create: Content {}
extension User: Content {}

private func withAppIncludingDB(_ test: (Application) async throws -> Void) async throws {
  let app = try await Application.make(.testing)
  do {
    try await configure(app)
    try await app.autoMigrate()
    try await test(app)
    try await app.autoRevert()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }
  try await app.asyncShutdown()
}

let env: Environment = {
  var env = Environment.testing
  try! LoggingSystem.bootstrap(from: &env)
  return env
}()
