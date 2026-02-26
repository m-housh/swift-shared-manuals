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
  case project
  case user(UserRoute)

  static let router = OneOf {
    Route(.case(Self.home)) {
      Method.get
    }
    Route(.case(Self.project)) {
      Path { "project" }
      Method.get
    }
    Route(.case(Self.user)) {
      UserRoute.router
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

    case .project:
      await ResultView {
        ProjectForm()
          .attributes(.class("p-10"))
      }

    case .user(let route):
      switch route {

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

      case .profile(let userID, let route):
        switch route {
        case .index:
          await ResultView {
            try await database.userProfiles.fetch(userID)
          } onSuccess: { profile in
            Modal(open: true, displayCloseButton: false) {
              UserProfileForm(userID: userID, profile: profile)
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
    div(.class("flex justify-center items-center mt-10 space-x-2 space-y-4")) {
      if let user {
        div {
          h1(.class("text-3xl font-bold")) { "Welcome \(user.email)." }
          button(
            .class("btn btn-primary"),
            .hx.get(route: SiteRoute.user(.logout)),
            .hx.target("#content"),
            .hx.swap(.innerHTML),
          ) {
            "Logout"
          }
          button(
            .class("btn btn-secondary"),
            .hx.get(route: SiteRoute.user(.profile(user.id, .index))),
            .hx.target(id: "content"),
            .hx.swap(.innerHTML)
          ) {
            "Profile"
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
