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
  func view(request: ViewRequest<Route>) async throws -> View
}

extension ViewController where View: Sendable {

  func respond(
    to route: Route,
    on request: Request
  ) async throws -> any AsyncResponseEncodable {
    @Dependency(\.mainPage) var mainPage

    let isHtmxRequest = request.headers.contains(name: "hx-request")
    let html = try await view(
      request: .init(isHtmxRequest: isHtmxRequest, route: route)
    )
    guard isHtmxRequest else {
      return try await AnyHTMLResponse(value: mainPage.embed(html))
    }
    return AnyHTMLResponse(value: html)
  }
}

// NOTE: Everything below is adapted / taken from https://github.com/vapor-community/vapor-elementary

// Re-adapted from `HTMLResponse` in the VaporElementary package to work with any html types
// returned from the view controller.
struct AnyHTMLResponse: AsyncResponseEncodable {

  public var chunkSize: Int
  public var headers: HTTPHeaders = ["Content-Type": "text/html; charset=utf-8"]
  var value: _SendableAnyHTMLBox

  init(chunkSize: Int = 1024, additionalHeaders: HTTPHeaders = [:], value: AnySendableHTML) {
    self.chunkSize = chunkSize
    if additionalHeaders.contains(name: .contentType) {
      self.headers = additionalHeaders
    } else {
      headers.add(contentsOf: additionalHeaders)
    }
    self.value = .init(value)
  }

  func encodeResponse(for request: Request) async throws -> Response {
    Response(
      status: .ok,
      headers: headers,
      body: .init(asyncStream: { [value, chunkSize] writer in
        guard let html = value.tryTake() else {
          assertionFailure("Non-sendable HTML value consumed more than once")
          request.logger.error("Non-sendable HTML value consumed more than once")
          throw Abort(.internalServerError)
        }
        try await writer.writeHTML(html, chunkSize: chunkSize)
        try await writer.write(.end)

      })
    )
  }
}

struct HTMLResponseBodyStreamWriter<Writer: AsyncBodyStreamWriter>: HTMLStreamWriter {
  let allocator: ByteBufferAllocator = .init()
  var writer: Writer

  mutating func write(_ bytes: ArraySlice<UInt8>) async throws {
    try await self.writer.writeBuffer(self.allocator.buffer(bytes: bytes))
  }
}

extension AsyncBodyStreamWriter {
  /// Writes HTML by rendering chunks of bytes to the response body
  ///
  /// - Parameters:
  ///   - html: The HTML content to render in the response
  ///   - chunkSize: The number of bytes to write to the response body at a time (default is 1024 bytes)
  public func writeHTML(_ html: consuming some HTML, chunkSize: Int = 1204) async throws {
    try await html.render(
      into: HTMLResponseBodyStreamWriter(writer: self),
      chunkSize: chunkSize
    )
  }
}
