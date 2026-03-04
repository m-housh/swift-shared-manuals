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

private enum ViewResponderKey: TestDependencyKey {
  static var testValue: any ViewResponder { UnimplementedViewResponder() }
}

private struct UnimplementedViewResponder: ViewResponder {
  func respond<View>(
    with view: View,
    on request: Vapor.Request
  ) async throws -> HTMLResponse where View: HTML, View: Sendable {
    unimplemented(placeholder: .init { view })
  }

}
