import AuthClient
import Dependencies
import Elementary
import LoggingDependency
import SharedMiddleware
import SharedModels
import SharedViews

extension DependencyValues {
  public var userViewController: any ViewController<UserRoute> {
    get { self[UserViewControllerKey.self] }
    set { self[UserViewControllerKey.self] = newValue }
  }
}

enum UserViewControllerKey: DependencyKey {
  static var testValue: any ViewController<UserRoute> {
    UnimplementedUserViewController()
  }
  static var liveValue: any ViewController<UserRoute> { LiveUserViewController() }
}

struct UnimplementedUserViewController: ViewController, Sendable {
  typealias Route = UserRoute

  func view(request: ViewRequest<UserRoute>) async throws -> AnySendableHTML {
    unimplemented(placeholder: EmptyHTML())
  }
}

struct LiveUserViewController: ViewController, Sendable {
  typealias Route = UserRoute

  @HTMLBuilder
  func view(request: ViewRequest<UserRoute>) async throws -> AnySendableHTML {
    @Dependency(\.auth) var auth
    @Dependency(\.logger) var logger

    switch request.route {
    case .login(let route):
      switch route {
      case .index(let next):
        LoginForm(style: .login, next: next)
      case .submit(let form):
        fatalError()
      }

    case .logout:
      await ResultView {
        try auth.logout()
      }

    case .profile(let route):
      fatalError()

    case .signup(let route):
      switch route {
      case .index:
        LoginForm(style: .signup)
      case .submit(let form):
        fatalError()
      }
    }
  }
}
