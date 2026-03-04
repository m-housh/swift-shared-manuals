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

public protocol ViewResponder: Sendable {
  func respond<View: HTML & Sendable>(
    with view: View,
    on request: Request
  ) async throws -> HTMLResponse
}

struct UnimplementedViewResponder: ViewResponder {
  func respond<View>(
    with view: View,
    on request: Vapor.Request
  ) async throws -> HTMLResponse where View: HTML, View: Sendable {
    unimplemented(placeholder: .init { view })
  }

}

enum ViewResponderKey: TestDependencyKey {
  static var testValue: any ViewResponder { UnimplementedViewResponder() }
}

extension DependencyValues {
  public var viewResponder: any ViewResponder {
    get { self[ViewResponderKey.self] }
    set { self[ViewResponderKey.self] = newValue }
  }
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
    .init { request in
      @Dependency(\.viewResponder) var viewResponder
      return try await viewResponder.respond(with: body(), on: request)
    }
  }

  public static func view<V: HTML>(
    @HTMLBuilder body: @escaping @Sendable () async throws -> V
  ) -> Self where V: Sendable {
    .init { request in
      @Dependency(\.viewResponder) var viewResponder
      return try await viewResponder.respond(with: body(), on: request)
    }
  }
}

extension Redirect: @retroactive @unchecked Sendable {}
