import Fluent
import FluentSQLiteDriver
import SharedMiddleware
import URLRouting
import Vapor
import VaporTesting

public protocol TestRouter<Route> {
  associatedtype Route
  associatedtype Router: ParserPrinter<URLRequestData, Route>

  static var router: Router { get }
}

extension TestingApplicationTester {
  @discardableResult
  public func test<R>(
    _ method: HTTPMethod,
    route: R,
    headers: HTTPHeaders = [:],
    body: ByteBuffer? = nil,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column,
    beforeRequest: (inout TestingHTTPRequest) async throws -> Void = { _ in },
    afterResponse: (TestingHTTPResponse) async throws -> Void = { _ in }
  ) async throws -> TestingApplicationTester where R: TestRouter, R.Route == R {
    try await test(
      method,
      R.router.path(for: route),
      headers: headers,
      body: body,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column,
      beforeRequest: beforeRequest,
      afterResponse: afterResponse
    )
  }

  @discardableResult
  public func test<R>(
    _ method: HTTPMethod,
    route: R,
    headers: HTTPHeaders = [:],
    body: ByteBuffer? = nil,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column,
    afterResponse: (TestingHTTPResponse) async throws -> Void = { _ in }
  ) async throws -> TestingApplicationTester where R: TestRouter, R.Route == R {
    try await test(
      method,
      R.router.path(for: route),
      headers: headers,
      body: body,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column,
      beforeRequest: { _ in },
      afterResponse: afterResponse
    )
  }
}
