import Elementary
import SharedModels

extension HTMLAttribute where Tag: HTMLTrait.Attributes.href {

  /// Add an `href` attribute for the given route.
  public static func href<Route>(
    route: Route
  ) -> Self where Route: Routeable {
    href(Route.router.path(for: route))
  }
}
