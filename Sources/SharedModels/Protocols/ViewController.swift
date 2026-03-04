import Dependencies
import Elementary
import Vapor
import VaporElementary

public protocol ViewController<Route>: Sendable {
  associatedtype Route

  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - route: The route to respond to.
  ///   - request: The incoming vapor request.
  func view(for route: Route, on request: Request) async throws -> ViewResponse
}
