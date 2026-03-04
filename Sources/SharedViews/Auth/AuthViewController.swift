import AuthClient
import Dependencies
import Elementary
import SharedModels
import SharedStyleguide
import Vapor

public struct AuthViewController: ViewController {

  @Dependency(\.auth) var auth

  public init() {}

  public func view(
    for route: SharedRoute.Auth,
    on request: Request
  ) async throws -> ViewResponse {
    switch route {
    case .logout:
      return .redirect(to: "/") {
        try auth.logout()
      }
    case .login(let route):
      switch route {
      case .index(let next):
        return .view {
          Modal(open: true, displayCloseButton: false) {
            LoginForm(next: next)
          }
        }
      case .submit(let form):
        return .redirect(to: form.next ?? "/") {
          _ = try await auth.login(form)
        }
      }
    }
  }
}
