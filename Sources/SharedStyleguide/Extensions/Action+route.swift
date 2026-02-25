import Elementary
import SharedModels

extension HTMLAttribute where Tag == HTMLTag.form {
  public static func action<R: Routeable>(route: R) -> Self {
    action(R.router.path(for: route))
  }
}
