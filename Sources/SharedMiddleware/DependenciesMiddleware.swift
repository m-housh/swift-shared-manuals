import Dependencies
import Vapor

// Taken from discussions page on `swift-dependencies`.

public struct DependenciesMiddleware: AsyncMiddleware {

  private let values: DependencyValues.Continuation
  private let setupDependencies: @Sendable (inout DependencyValues, Request) -> Void

  public init(
    setupDependencies: @escaping @Sendable (inout DependencyValues, Request) -> Void
  ) {
    self.values = withEscapedDependencies { $0 }
    self.setupDependencies = setupDependencies
  }

  public func respond(
    to request: Request,
    chainingTo next: any AsyncResponder
  ) async throws -> Response {
    try await withDependencies {
      self.setupDependencies(&$0, request)
    } operation: {
      try await next.respond(to: request)
    }
  }
}
