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

struct SiteViewController: ViewController {
  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database
  @Dependency(\.logger) var logger

  typealias Route = SiteRoute

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
      switch route {
      case .auth(let route):
        await route.view()

      case .privacyPolicy:
        PrivacyPolicyView()
      case .project(let route):
        await route.view()
      case .user(let route):
        switch route {

        case .profile(let userID, let route):
          switch route {
          case .index:
            await ResultView {
              guard let profile = try await database.userProfiles.fetch(userID) else {
                throw NotFoundError()
              }
              return profile
            } onSuccess: { profile in
              PageView {
                UserProfileView(profile: profile)
              }
            }
          case .update(let id, let form):

            await ResultView {
              logger.debug("Updating profile: \(form)")
              let profile = try await database.userProfiles.update(id, form)
              return (
                try await database.users.get(profile.userID),
                profile.theme
              )
            } onSuccess: { user, theme in
              PageContent(theme: theme) {
                HomePage(user: user)
              }
            }
          }

        case .signup(.index):
          await ResultView {
            Modal(open: true, displayCloseButton: false) {
              SignupForm()
            }
          }
        case .signup(.submit(let form)):
          await ResultView {
            try await auth.createAndLogin(form)
          } onSuccess: { user in
            Modal(open: true, displayCloseButton: false) {
              UserProfileForm(userID: user.id, signup: true)
            }
          }
        case .signup(.submitProfile(let profile)):
          await ResultView {
            let profile = try await database.userProfiles.create(profile)
            return profile.theme
          } onSuccess: { theme in
            PageContent(theme: theme) {
              LoggedIn(next: nil)
            }
          }

        }
      }
    }
  }
}

extension SharedRoute.Auth {
  @HTMLBuilder
  func view() async -> (some HTML & Sendable) {
    @Dependency(\.auth) var auth
    @Dependency(\.sharedDatabase) var database

    switch self {

    case .login(.index(next: let next)):
      await ResultView {
        Modal(open: true, displayCloseButton: false) {
          LoginForm(next: next)
        }
      }
    case .login(.submit(let form)):
      await ResultView {
        let user = try await auth.login(form)
        let theme = try await database.userProfiles.theme(user.id)
        return (form.next, theme)
      } onSuccess: { (next, theme) in
        PageContent(theme: theme) {
          LoggedIn(next: next)
        }
      }

    case .logout:
      await ResultView {
        try auth.logout()
      } onSuccess: {
        HomePage(user: nil)
      }
    }
  }
}

extension Project.ViewRoute {
  @HTMLBuilder
  func view() async -> (some HTML & Sendable) {
    @Dependency(\.auth) var auth
    @Dependency(\.sharedDatabase) var database

    switch self {
    case .delete(let id):
      await ResultView {
        try await database.projects.delete(id)
      }
    case .detail(let id):
      await ResultView {
        guard let project = try await database.projects.get(id) else {
          throw NotFoundError()
        }
        return project
      } onSuccess: { project in
        PageView {
          ProjectDetail(project: project)
        }
      }
    case .index:
      await ResultView {
        let user = try auth.currentUser()
        return (
          user.id,
          try await database.projects.fetch(user.id, .first)
        )
      } onSuccess: { userID, projects in
        PageView {
          ProjectsTable(userID: userID, projects: projects)
        }
      }
    case .page(let page):
      await ResultView {
        let user = try auth.currentUser()
        return try await database.projects.fetch(user.id, page)
      } onSuccess: { projects in
        ProjectsTable.Rows(projects: projects)
      }

    case .submit(let form):
      await ResultView {
        // Create the project then reload the rows, just for this dev server.
        // Real app would navigate to project detail route.
        let user = try auth.currentUser()
        let _ = try await database.projects.create(user.id, form)
        return (
          user.id,
          try await database.projects.fetch(user.id, .first)
        )
      } onSuccess: { userID, projects in
        PageView {
          ProjectsTable(userID: userID, projects: projects)
        }
      }

    default:
      fatalError()
    }
  }
}
