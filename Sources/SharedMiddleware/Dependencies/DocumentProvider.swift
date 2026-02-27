import AuthClient
import Dependencies
import DependenciesMacros
import Elementary
import SharedDatabase
import SharedModels
import SharedViews

extension DependencyValues {
  public var document: DocumentProvider {
    get { self[DocumentProvider.self] }
    set { self[DocumentProvider.self] = newValue }
  }
}

@DependencyClient
public struct DocumentProvider: Sendable {
  public var embed: @Sendable (AnySendableHTML) async throws -> AnySendableHTMLDocument
}

extension DocumentProvider: TestDependencyKey {
  public static let testValue = Self()

  public static func live<Head: HTML>(
    title: String,
    @HTMLBuilder head: @escaping @Sendable () -> Head
  ) -> Self where Head: Sendable {

    @Dependency(\.auth) var auth
    @Dependency(\.sharedDatabase) var database
    @Dependency(\.logger) var logger

    return .init(embed: { html in

      logger.debug("Begin embed...")

      var theme: Theme? = nil
      let htmlString = try await html.renderAsync()
      let currentUser = try? auth.currentUser()
      if let currentUser {
        theme = try await database.userProfiles.theme(currentUser.id)
      }
      logger.debug("Theme: \(String(describing: theme))")
      logger.debug("End embed...")

      return MainDocument(title: "Dev Server", theme: theme) {
        DefaultHead { head() }
      } body: {
        HTMLRaw(htmlString)
      }
    })
  }

  public static func live(title: String) -> Self {
    live(title: title) { EmptyHTML() }
  }
}
