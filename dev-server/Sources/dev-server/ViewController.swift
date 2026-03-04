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
  ) async throws -> some HTML & Sendable {
    try await projectController.view(for: route, on: request)
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

  @HTMLBuilder
  func view(for route: SiteRoute, on request: Request) async throws -> (some HTML & Sendable) {
    switch route {
    case .home:
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

    case .shared(let route):
      try await sharedViewController.view(for: route, on: request)
    }
  }
}
