import Dependencies
import Elementary
import SharedModels
import Vapor

public protocol ViewController<Route>: Sendable, URLRouteResponder {
  /// Respond to the given view request / route.
  ///
  /// - Parameters:
  ///   - request: The view request.
  func view(request: ViewRequest<Route>) async throws -> AnySendableHTML
}

extension ViewController {
  /// Uses the view responder dependency to transform the html output to
  /// a `Response` for vapor.
  ///
  /// See: ``URLRouteResponder``
  public func respond(
    to route: Route,
    on request: Request
  ) async throws -> any AsyncResponseEncodable {
    @Dependency(\.viewResponder) var responder

    let isHtmxRequest = request.headers.contains(name: "hx-request")
    let html = try await view(
      request: .init(isHtmxRequest: isHtmxRequest, route: route)
    )

    return try await responder.respond(
      .init(isHtmxRequest: isHtmxRequest, html: html)
    )
  }
}
