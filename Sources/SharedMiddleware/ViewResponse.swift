import Elementary

public struct ViewResponse: Sendable {

  public let isHtmxRequest: Bool
  public let html: AnySendableHTML

  public init(isHtmxRequest: Bool, html: AnySendableHTML) {
    self.isHtmxRequest = isHtmxRequest
    self.html = html
  }
}
