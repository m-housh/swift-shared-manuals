import Dependencies
import Elementary
import SharedModels
import Vapor

// TODO: Remove error and just make async ??
public protocol ViewController<Route>: Sendable {
  associatedtype Route
  associatedtype View: HTML

  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - request: The view request.
  @HTMLBuilder
  func view(request: ViewRequest<Route>) async throws -> View
}
