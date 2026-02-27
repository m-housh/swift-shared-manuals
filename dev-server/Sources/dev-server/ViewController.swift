import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
@preconcurrency import URLRouting

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
  func view(request: ViewRequest<SiteRoute>) async throws -> (some HTML & Sendable) {
    switch request.route {
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
        MainContent(theme: theme) {
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
              UserProfileView(profile: profile)
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
              MainContent(theme: theme) {
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
            MainContent(theme: theme) {
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
        MainContent(theme: theme) {
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
      } onSuccess: {
        ProjectDetail(project: $0)
          .attributes(.class("mx-10 mt-6"))
      }
    case .index:
      await ResultView {
        let user = try auth.currentUser()
        return (
          user.id,
          try await database.projects.fetch(user.id, .first)
        )
      } onSuccess: { userID, projects in
        ProjectsTable(userID: userID, projects: projects)
          .attributes(.class("mx-10 mt-6"))
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
        ProjectsTable(userID: userID, projects: projects)
          .attributes(.class("mx-10 mt-6"))
      }

    default:
      fatalError()
    }
  }
}

struct LoggedIn: HTML, Sendable {
  let next: String

  init(next: String?) {
    self.next = next ?? SiteRoute.router.path(for: .home)
  }

  var body: some HTML {
    div(
      .hx.get(next),
      .hx.pushURL(true),
      .hx.target("#content"),
      .hx.swap(.innerHTML),
      .hx.trigger(.event(.revealed)),
      .hx.indicator()
    ) {
      Indicator()
    }
  }
}

struct HomePage: HTML, Sendable {
  let user: User?

  var body: some HTML {
    div(.class("flex mt-10 justify-center items-center")) {
      if let user {
        div(.class("space-y-4")) {
          h1(.class("text-3xl font-bold")) { "Welcome \(user.email)." }
          div(.class("flex space-x-4 justify-center")) {
            button(
              .class("btn btn-primary"),
              .hx.get(route: SiteRoute.shared(.auth(.logout))),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
            ) {
              "Logout"
            }
            button(
              .class("btn btn-secondary"),
              .hx.get(route: SiteRoute.user(.profile(user.id, .index))),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
              .hx.pushURL(true)
            ) {
              "Profile"
            }
            button(
              .class("btn btn-accent"),
              .hx.get(route: SiteRoute.project(.index)),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
              .hx.pushURL(true)
            ) {
              "Projects"
            }
          }
        }
      } else {
        Modal(open: true, displayCloseButton: false) {
          LoginForm()
        }
      }
    }
  }
}
