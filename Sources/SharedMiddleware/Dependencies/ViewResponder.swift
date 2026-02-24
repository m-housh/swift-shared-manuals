import Dependencies
import Elementary
import Vapor
import VaporElementary

extension DependencyValues {
  public var viewResponder: any ViewResponder {
    get { self[ViewResponderKey.self] }
    set { self[ViewResponderKey.self] = newValue }
  }
}

public protocol ViewResponder: Sendable {
  func respond(_ viewResponse: ViewResponse) async throws -> any AsyncResponseEncodable
}

enum ViewResponderKey: DependencyKey {
  static var testValue: any ViewResponder { UnimplementedViewResponder() }
  static var liveValue: any ViewResponder { DefaultViewResponder() }
}

struct UnimplementedViewResponder: ViewResponder {
  func respond(_ viewResponse: ViewResponse) async throws -> any AsyncResponseEncodable {
    unimplemented(placeholder: AnyHTMLResponse(value: EmptyHTML()))
  }
}

struct DefaultViewResponder: ViewResponder {
  func respond(_ viewResponse: ViewResponse) async throws -> any AsyncResponseEncodable {
    @Dependency(\.mainPage) var mainPage
    guard viewResponse.isHtmxRequest else {
      return try await AnyHTMLResponse(value: mainPage.embed(html: viewResponse.html))
    }
    return AnyHTMLResponse(value: viewResponse.html)
  }
}

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
