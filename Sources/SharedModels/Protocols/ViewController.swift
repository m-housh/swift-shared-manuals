import Dependencies
import Elementary
import Vapor

public protocol ViewController<Route>: Sendable {
  associatedtype Route
  associatedtype View: HTML & Sendable

  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - request: The view request.
  @HTMLBuilder
  func view(for route: Route, on request: Request) async throws -> View
}
