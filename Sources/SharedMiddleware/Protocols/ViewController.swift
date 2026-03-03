import Dependencies
import Elementary
import SharedModels
import Vapor

public protocol ViewController<Route>: Sendable {
  associatedtype Route
  associatedtype View: HTML

  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - request: The view request.
  @HTMLBuilder
  func view(for route: Route, on request: Request) async throws -> View
}
