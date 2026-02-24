public struct ViewRequest<Route> {
  public let isHtmxRequest: Bool
  public let route: Route

  public init(
    isHtmxRequest: Bool,
    route: Route
  ) {
    self.isHtmxRequest = isHtmxRequest
    self.route = route
  }
}

extension ViewRequest: Sendable where Route: Sendable {}
extension ViewRequest: Equatable where Route: Equatable {}
