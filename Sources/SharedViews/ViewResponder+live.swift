import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedModels
import Vapor
import VaporElementary

extension ViewResponder {

  public static func live<Head: HTML>(
    title: String,
    language: String = "en",
    @HTMLBuilder head: () -> Head
  ) -> Self where Self == LiveViewResponder<Head>, Head: Sendable {
    .init(title: title, language: language, head: head())
  }
}

public struct LiveViewResponder<Head: HTML>: ViewResponder where Head: Sendable {

  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database
  @Dependency(\.logger) var logger

  let title: String
  let language: String
  let head: Head

  public func respond<View>(
    with view: View,
    on request: Vapor.Request
  ) async throws -> HTMLResponse where View: HTML, View: Sendable {
    logger.debug("Begin live view responder...")
    guard request.headers.contains(name: "hx-request") else {
      logger.debug("Begin embed in document...")
      var theme: Theme? = nil
      if let currentUser = try? auth.currentUser() {
        theme = try await database.userProfiles.theme(currentUser.id)
      }
      logger.trace("End embed in document...")
      return .init {
        MainDocument(
          title: title,
          language: language,
          theme: theme,
          head: { head },
          body: { view }
        )
      }
    }

    return .init { view }
  }

}
