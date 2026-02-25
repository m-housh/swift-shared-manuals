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
  case user(UserRoute)

  static let router = OneOf {
    Route(.case(Self.home)) {
      Method.get
    }
    Route(.case(Self.user)) {
      UserRoute.router
    }
  }
}

struct SiteViewController: ViewController {
  typealias Route = SiteRoute

  func view(request: ViewRequest<SiteRoute>) async throws -> AnySendableHTML {
    @Dependency(\.logger) var logger
    @Dependency(\.auth) var auth

    switch request.route {

    case .home:
      let currentUser = try? auth.currentUser()
      logger.debug("Current user: \(currentUser?.email ?? "nil")")
      return HomePage(user: currentUser)

    case .user(let route):
      switch route {

      case .login(.index(next: let next)):
        return Modal(open: true, displayCloseButton: false) {
          LoginForm(next: next)
        }
      case .login(.submit(let form)):
        return await ResultView {
          _ = try await auth.login(form)
          return form.next
        } onSuccess: {
          LoggedIn(next: $0)
        }

      case .logout:
        return await ResultView {
          try auth.logout()
        } onSuccess: {
          HomePage(user: nil)
        }

      case .signup(.index):
        return Modal(open: true, displayCloseButton: false) {
          SignupForm()
        }
      case .signup(.submit(let form)):
        return await ResultView {
          try await auth.createAndLogin(form)
        } onSuccess: { user in
          // LoggedIn(next: nil)
          HomePage(user: user)
        }

      default:
        fatalError()
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
    div(.class("flex justify-center items-center mt-10")) {
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
        }
      } else {
        LoginForm()
      }
    }
  }
}
