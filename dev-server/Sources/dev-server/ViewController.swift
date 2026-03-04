import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
@preconcurrency import URLRouting
import Vapor
import VaporElementary

enum SiteRoute: Routeable {
  case home
  case shared(SharedRoute)

  static func user(_ route: User.ViewRoute) -> Self {
    .shared(.user(route))
  }

  static func project(_ route: Project.ViewRoute) -> Self {
    .shared(.project(route))
  }

  static let router = OneOf {
    Route(.case(Self.home)) {
      Method.get
    }
    Route(.case(Self.shared)) {
      SharedRoute.router
    }
  }
}

struct MyProjectController: ViewController {

  let projectController = ProjectViewController { _ in
    await ResultView {
      @Dependency(\.auth) var auth
      @Dependency(\.sharedDatabase) var database
      let user = try auth.currentUser()
      return (
        user.id,
        try await database.projects.fetch(user.id, .first)
      )
    } onSuccess: {
      ProjectsTable(userID: $0, projects: $1)
    }
  }

  func view(
    for route: Project.ViewRoute,
    on request: Request
  ) async throws -> ViewResponse {
    try await projectController.view(for: route, on: request)
  }
}

struct MyViewResponder: ViewResponder {
  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database
  @Dependency(\.logger) var logger

  func respond<View>(
    with view: View,
    on request: Request
  ) async throws -> HTMLResponse where View: HTML, View: Sendable {
    guard request.headers.contains(name: "hx-request") else {
      logger.info("Begin embed in document...")
      var theme: Theme? = nil
      if let currentUser = try? auth.currentUser() {
        theme = try await database.userProfiles.theme(currentUser.id)
      }
      logger.info("Theme: \(String(describing: theme))")
      logger.info("End embed...")

      return .init {
        MainDocument(title: "Dev server", theme: theme) {
          DefaultHead()
        } body: {
          view
        }
      }
    }
    return .init { view }
  }
}

struct SiteViewController: ViewController {

  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database
  @Dependency(\.logger) var logger

  typealias Route = SiteRoute

  let sharedViewController = SharedViewController(
    auth: AuthViewController { nextRoute in
      LoggedIn(next: nextRoute)
    },
    projects: MyProjectController(),
    users: UserViewController()
  )

  func view(for route: SiteRoute, on request: Request) async throws -> ViewResponse {
    switch route {
    case .home:
      return .view {
        await ResultView {
          var theme: Theme? = nil
          let currentUser = try? auth.currentUser()
          logger.debug("Current user: \(currentUser?.email ?? "nil")")
          if let currentUser {
            theme = try await database.userProfiles.theme(currentUser.id)
          }
          return (currentUser, theme)
        } onSuccess: { user, theme in
          PageContent(theme: theme) {
            HomePage(user: user)
          }
        }
      }

    case .shared(let route):
      return try await sharedViewController.view(for: route, on: request)
    }
  }
}
