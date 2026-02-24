import Elementary
import SharedModels
import Vapor

public protocol ViewController<Route>: Sendable {
  associatedtype Route: Sendable

  func view(request: ViewRequest<Route>) async throws -> AnySendableHTML
}

extension ViewController {

  public func viewResponse(
    _ request: Request,
    _ route: Route
  ) async throws -> ViewResponse {
    let isHtmxRequest = request.headers.contains(name: "hx-request")
    let html = try await view(
      request: .init(isHtmxRequest: isHtmxRequest, route: route)
    )
    return .init(isHtmxRequest: isHtmxRequest, html: html)
  }
}
