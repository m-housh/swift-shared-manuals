import Dependencies
import Elementary
import Vapor

/// Represents a response type returned from a view controller context.
///
/// This is generally used along with a ``ViewResponder`` in order to
/// embed the view inside a full html document when appropriate.
///
///
public struct ViewResponse: Sendable {
  public let makeResponse: @Sendable (Request) async throws -> any AsyncResponseEncodable

  init(
    makeResponse: @escaping @Sendable (Request) async throws -> any AsyncResponseEncodable
  ) {
    self.makeResponse = makeResponse
  }

  /// Redirect to the given route.
  ///
  /// - Parameters:
  ///   - route: The route redirect to.
  ///   - redirectType: The redirection type.
  public static func redirect(
    to route: String,
    redirectType: Redirect = .normal
  ) -> Self {
    .init { $0.redirect(to: route, redirectType: redirectType) }
  }

  /// Redirect to the given route after performing the given closure.
  ///
  /// - Parameters:
  ///   - route: The route redirect to.
  ///   - redirectType: The redirection type.
  ///   - catching: The closure to call before redirecting.
  public static func redirect(
    to route: String,
    redirectType: Redirect = .normal,
    catching: @escaping @Sendable () async throws -> Void
  ) -> Self {
    .init { request in
      try await catching()
      return request.redirect(to: route, redirectType: redirectType)
    }
  }

  /// Respond with the given html view.
  ///
  /// - Parameters:
  ///   - body: The html to respond with.
  public static func view<V: HTML>(
    @HTMLBuilder body: @escaping @Sendable () -> V
  ) -> Self where V: Sendable {
    .init { request in
      @Dependency(\.viewResponder) var viewResponder
      return try await viewResponder.respond(with: body(), on: request)
    }
  }

  /// Respond with the given html view.
  ///
  /// - Parameters:
  ///   - body: The html to respond with.
  public static func view<V: HTML>(
    @HTMLBuilder body: @escaping @Sendable () async -> V
  ) -> Self where V: Sendable {
    .init { request in
      @Dependency(\.viewResponder) var viewResponder
      return try await viewResponder.respond(with: body(), on: request)
    }
  }
}

extension Redirect: @retroactive @unchecked Sendable {}
