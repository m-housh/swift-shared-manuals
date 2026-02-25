import Dependencies
import Vapor

public protocol URLRouteResponder: Sendable {
  associatedtype Route

  /// Generate a vapor `Response` for the given route.
  ///
  /// - Paramaters:
  ///   - route: The parsed route to respond to.
  ///   - request: The incoming vapor request object.
  func respond(
    to route: Route,
    on request: Request
  ) async throws -> any AsyncResponseEncodable
}
