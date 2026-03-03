import AuthClient
import Dependencies
import Elementary
import SharedModels
import SharedStyleguide
import Vapor

public struct AuthViewController<Next: HTML>: ViewController where Next: Sendable {

  @Dependency(\.auth) var auth
  private let nextView: @Sendable (String?) async -> Next

  public init(
    @HTMLBuilder next: @escaping @Sendable (String?) async -> Next
  ) {
    self.nextView = next
  }

  @HTMLBuilder
  public func view(
    for route: SharedRoute.Auth,
    on request: Request
  ) async throws -> (some HTML & Sendable) {
    switch route {
    case .logout:
      await ResultView {
        try auth.logout()
        return await nextView(nil)
      } onSuccess: {
        $0
      }
    case .login(let route):
      switch route {
      case .index(let next):
        Modal(open: true, displayCloseButton: false) {
          LoginForm(next: next)
        }
      case .submit(let form):
        await ResultView {
          _ = try await auth.login(form)
          return await nextView(form.next)
        } onSuccess: {
          $0
        }
      }
    }
  }
}
