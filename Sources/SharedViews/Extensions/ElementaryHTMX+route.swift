import Elementary
import ElementaryHTMX
import SharedModels

extension HTMLAttribute.hx {
  
  /// Add an htmx delete attribute for the given route.
  public static func delete<Route>(
    route: Route
  ) -> HTMLAttribute where Route: Routeable {
    delete(Route.router.path(for: route))
  }

  /// Add an htmx get attribute for the given route.
  public static func get<Route>(
    route: Route
  ) -> HTMLAttribute where Route: Routeable {
    get(Route.router.path(for: route))
  }

  /// Add an htmx patch attribute for the given route.
  public static func patch<Route>(
    route: Route
  ) -> HTMLAttribute where Route: Routeable {
    patch(Route.router.path(for: route))
  }

  /// Add an htmx post attribute for the given route.
  public static func post<Route>(
    route: Route
  ) -> HTMLAttribute where Route: Routeable {
    post(Route.router.path(for: route))
  }

  /// Add an htmx put attribute for the given route.
  public static func put<Route>(
    route: Route
  ) -> HTMLAttribute where Route: Routeable {
    put(Route.router.path(for: route))
  }
}
