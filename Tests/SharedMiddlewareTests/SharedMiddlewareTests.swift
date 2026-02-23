import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import Foundation
import LoggingDependency
import SharedDatabase
import SharedModels
import SharedTestSupport
import Testing
@preconcurrency import URLRouting
import Vapor
import VaporRouting
import VaporTesting

@testable import SharedMiddleware

enum TestRoute: Sendable, Routeable {

  typealias Route = TestRoute

  case createUser(User.Create)
  case loggedIn

  static let router = OneOf {
    URLRouting.Route(.case(Self.createUser)) {
      Path { "users" }
      Method.post
      Body(.json(User.Create.self))
    }
    URLRouting.Route(.case(Self.loggedIn)) {
      Path { "home" }
      Method.get
    }
  }
}

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

          let cookie = res.headers.setCookie?["vapor-session"]
          #expect(cookie != nil)

          print("COOKIE: \(String(describing: cookie))")
          var headers = HTTPHeaders()
          var cookies = HTTPCookies()
          cookies["vapor-session"] = cookie
          headers.cookie = cookies
          try await app.testing().test(.GET, route: TestRoute.loggedIn, headers: headers) { resp in
            #expect(resp.status == .ok)
          }
        })

      try await app.testing().test(.GET, route: TestRoute.loggedIn) { req in
        req.headers.basicAuthorization = .init(
          username: "testy@example.com", password: "super-secret"
        )
      } afterResponse: { res in
        #expect(res.status == .ok)
      }

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

extension User.Create: Content {}
extension User: Content {}

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

private func withAppIncludingDB(
  _ test: @escaping @Sendable (Application) async throws -> Void
) async throws {
  try await withTestAppAndDatabase { app, _ in
    app.middleware.use(app.sessions.middleware)
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

    try await test(app)
  }
}

let env: Environment = {
  var env = Environment.testing
  try! LoggingSystem.bootstrap(from: &env)
  return env
}()
