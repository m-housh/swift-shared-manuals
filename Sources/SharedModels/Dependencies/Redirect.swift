import Dependencies
import DependenciesMacros
import Vapor

extension DependencyValues {
  public var redirect: RedirectClient {
    get { self[RedirectClient.self] }
    set { self[RedirectClient.self] = newValue }
  }
}

@DependencyClient
public struct RedirectClient: Sendable {
  public var redirect: @Sendable (String?) async throws -> any AsyncResponseEncodable
}

extension RedirectClient: TestDependencyKey {
  public static let testValue = Self()

  public static func live(on request: Request) -> Self {
    .init { next in
      return request.redirect(to: next ?? "/")
    }
  }
}
