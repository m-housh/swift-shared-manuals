import Dependencies
import SharedModels
import URLRouting
import Vapor
import VaporRouting

// Taken from github.com/nevillco/vapor-routing

// Usage:
// app.mount(
//   router,
//   routeMiddleware: { route in
//     case .onboarding: return nil
//     case .signIn: return BasicAuthMiddleware()
//     default: return BearerAuthMiddleware()
//   },
//   use: { request, route in
//     // route handling
//   }
// )
extension Application {
  /// Mounts a router to the Vapor application.
  ///
  /// See ``VaporRouting`` for more information on usage.
  ///
  /// - Parameters:
  ///   - router: A parser-printer that works on inputs of `URLRequestData`.
  ///   - middleware: A closure for providing any per-route middlewares to be run before processing the request.
  ///   - closure: A closure that takes a `Request` and the router's output as arguments.
  public func mount<R: Parser>(
    _ router: R,
    routeMiddleware middleware: @escaping @Sendable (R.Output) -> [any Middleware]? = { _ in nil },
    use closure: @escaping @Sendable (Request, R.Output) async throws -> any AsyncResponseEncodable
  ) where R.Input == URLRequestData, R: Sendable, R.Output: Sendable {
    self.middleware.use(
      AsyncRoutingMiddleware(
        router: router,
        middleware: middleware,
        respond: closure
      )
    )
  }

  /// Mounts a router and route controller to the Vapor application.
  ///
  /// See ``VaporRouting`` for more information on usage.
  ///
  /// - Parameters:
  ///   - router: A parser-printer that works on inputs of `URLRequestData`.
  ///   - controller: A route controller that takes a `Request` and the router's output and generates a response.
  ///   - middleware: A closure for providing any per-route middlewares to be run before processing the request.
  public func mount<R: Parser, V: ViewController>(
    _ router: R,
    controller: V,
    routeMiddleware middleware: @escaping @Sendable (V.Route) -> [any Middleware]? = { _ in nil }
  )
  where
    R.Output == V.Route,
    R: Sendable,
    R.Output: Sendable,
    R.Input == URLRequestData,
    V: Sendable
  {
    mount(
      router,
      routeMiddleware: middleware,
      use: controller.siteHandler
    )
  }

  /// Mounts a router and route controller to the Vapor application.
  ///
  /// See ``VaporRouting`` for more information on usage.
  ///
  /// - Parameters:
  ///   - controller: A route controller that takes a `Request` and the router's output and generates a response.
  ///   - middleware: A closure for providing any per-route middlewares to be run before processing the request.
  public func mount<C: ViewController>(
    controller: C,
    routeMiddleware middleware: @escaping @Sendable (C.Route) -> [any Middleware]? = { _ in nil }
  )
  where
    C: Sendable,
    C.Route: Routeable,
    C.Route.Router: Sendable,
    C.Route.Router.Output: Sendable
  {
    mount(
      C.Route.router,
      routeMiddleware: middleware,
      use: controller.siteHandler
    )
  }
}

/// Serves requests using a router and response handler.
///
/// You will not typically need to interact with this type directly. Instead you should use the
/// `mount` method on your Vapor application.
///
/// See ``VaporRouting`` for more information on usage.
private struct AsyncRoutingMiddleware<Router: Parser>: AsyncMiddleware
where
  Router.Input == URLRequestData,
  Router: Sendable,
  Router.Output: Sendable
{
  let router: Router
  let middleware: @Sendable (Router.Output) -> [any Middleware]?
  let respond: @Sendable (Request, Router.Output) async throws -> any AsyncResponseEncodable

  public func respond(
    to request: Request,
    chainingTo next: any AsyncResponder
  ) async throws -> Response {
    if request.body.data == nil {
      try await _ = request.body.collect(max: request.application.routes.defaultMaxBodySize.value)
        .get()
    }

    guard let requestData = URLRequestData(request: request)
    else { return try await next.respond(to: request) }

    let route: Router.Output
    do {
      route = try router.parse(requestData)
    } catch let routingError {
      do {
        return try await next.respond(to: request)
      } catch {
        request.logger.info("\(routingError)")

        guard request.application.environment == .development
        else { throw error }

        return Response(status: .notFound, body: .init(string: "Routing \(routingError)"))
      }
    }

    if let middleware = middleware(route) {
      return try await middleware.makeResponder(
        chainingTo: AsyncBasicResponder { request in
          try await self.respond(request, route).encodeResponse(for: request)
        }
      ).respond(to: request).get()

    } else {
      return try await respond(request, route).encodeResponse(for: request)
    }
  }
}

extension ViewController where View: Sendable {
  fileprivate func siteHandler(
    _ request: Request,
    _ route: Route
  ) async throws -> any AsyncResponseEncodable {
    try await view(for: route, on: request)
  }
}

extension ViewResponse: AsyncResponseEncodable {

  public func encodeResponse(for request: Request) async throws -> Response {
    try await makeResponse(request).encodeResponse(for: request)
  }
}
