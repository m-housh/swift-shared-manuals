import Dependencies
import Elementary
import Vapor
import VaporElementary

public protocol ViewController<Route>: Sendable {
  associatedtype Route
  // associatedtype View: HTML & Sendable

  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - request: The view request.
  // @HTMLBuilder
  func view(for route: Route, on request: Request) async throws -> ViewResponse
}

// FIX: Need to embed in a document if not an htmx request.
public struct ViewResponse: Sendable {
  public let makeResponse: @Sendable (Request) async throws -> any AsyncResponseEncodable

  init(
    makeResponse: @escaping @Sendable (Request) async throws -> any AsyncResponseEncodable
  ) {
    self.makeResponse = makeResponse
  }

  public static func redirect(
    to route: String,
    redirectType: Redirect = .normal
  ) -> Self {
    .init { $0.redirect(to: route, redirectType: redirectType) }
  }

  public static func view<V: HTML>(
    @HTMLBuilder body: @escaping @Sendable () -> V
  ) -> Self where V: Sendable {
    .init { _ in
      HTMLResponse { body() }
    }
  }

  public static func view<V: HTML>(
    @HTMLBuilder body: @escaping @Sendable () async throws -> V
  ) -> Self where V: Sendable {
    .init { _ in
      let view = try await body()
      return HTMLResponse { view }
    }
  }
}

extension Redirect: @retroactive @unchecked Sendable {}
