import SharedDatabase
import SharedModels
import Vapor

extension User {
  public static func viewAuthMiddleware() -> [any Middleware] {
    [
      User.passwordAuth(),
      User.sessionAuth(),
      User.redirectMiddleware(
        path: SharedRoute.router.path(for: .auth(.login(.index())))
      ),
    ]
  }
}

extension SharedRoute {

  public func viewMiddleware() -> [any Middleware]? {
    switch self {
    case .auth(.login),
      .user(.signup),
      .privacyPolicy:
      return nil
    case .user(.profile),
      .auth(.logout),
      .project:
      return User.viewAuthMiddleware()
    }
  }
}
