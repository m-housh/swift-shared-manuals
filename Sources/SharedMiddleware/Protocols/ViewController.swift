import Elementary
import Vapor

public protocol ViewController<Route>: Sendable {
  associatedtype Route

  func view(request: ViewRequest<Route>) async throws -> AnySendableHTML
}

extension ViewController {

  public func respond(
    route: Route,
    on request: Request
  ) async throws -> ViewResponse {
    let isHtmxRequest = request.headers.contains(name: "hx-request")
    let html = try await view(
      request: .init(isHtmxRequest: isHtmxRequest, route: route)
    )
    return .init(isHtmxRequest: isHtmxRequest, html: html)
  }
}
