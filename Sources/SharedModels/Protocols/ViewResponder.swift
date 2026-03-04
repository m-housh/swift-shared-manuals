import Elementary
import Vapor
import VaporElementary

public protocol ViewResponder: Sendable {
  func respond<View: HTML>(
    with view: View,
    on request: Request
  ) async throws -> HTMLResponse where View: Sendable
}
