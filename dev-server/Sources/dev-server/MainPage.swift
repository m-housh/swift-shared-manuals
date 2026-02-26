import Dependencies
import Elementary
import ElementaryHTMX
import Foundation
import SharedMiddleware
import SharedModels

struct MyMainPage: MainPage {
  func embed(html: AnySendableHTML) async throws -> any SendableHTMLDocument {
    @Dependency(\.auth) var auth
    @Dependency(\.sharedDatabase) var database
    @Dependency(\.logger) var logger

    var theme: Theme? = nil
    let htmlString = try await html.renderAsync()
    let currentUser = try? auth.currentUser()
    if let currentUser {
      theme = try await database.userProfiles.theme(currentUser.id)
    }
    logger.debug("Theme: \(String(describing: theme))")

    return MainPageView(theme: theme) {
      HTMLRaw(htmlString)
    }
  }
}

struct MainPageView<Inner: HTML>: SendableHTMLDocument where Inner: Sendable {

  public var title: String { "Dev Server" }
  public var lang: String { "en" }

  let inner: Inner
  let theme: Theme?
  let displayFooter: Bool

  init(
    displayFooter: Bool = true,
    theme: Theme? = nil,
    _ inner: () -> Inner
  ) {
    self.displayFooter = displayFooter
    self.theme = theme
    self.inner = inner()
  }

  var head: some HTML {
    meta(.charset(.utf8))
    meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
    script(.src("https://unpkg.com/htmx.org@2.0.8")) {}
    script(.src("https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4")) {}
    link(
      .href("https://cdn.jsdelivr.net/npm/daisyui@5"),
      .rel(.stylesheet),
      .init(name: "type", value: "text/css")
    )
    link(
      .href("https://cdn.jsdelivr.net/npm/daisyui@5/themes.css"),
      .rel(.stylesheet),
      .init(name: "type", value: "text/css")
    )
    script(
      .src("https://unpkg.com/htmx-remove@latest"),
      .crossorigin(.anonymous),
      .integrity("sha384-NwB2Xh66PNEYfVki0ao13UAFmdNtMIdBKZ8sNGRT6hKfCPaINuZ4ScxS6vVAycPT")
    ) {}
    style {
      """
      .htmx-added {
        opacity: 0;
      }
      .htmx-swapping {
        opacity: 1;
        transition: opacity 1s ease-out;
      }
      """
    }
  }

  var body: some HTML {
    MainContent(inner, theme: theme)
  }
}

struct MainContent<Inner: HTML>: HTML, Sendable where Inner: Sendable {
  static var id: String { "content" }
  let theme: Theme
  let inner: Inner

  init(theme: Theme? = nil, @HTMLBuilder body: () -> Inner) {
    self.theme = theme ?? .default
    self.inner = body()
  }

  init(_ body: Inner, theme: Theme? = nil) {
    self.theme = theme ?? .default
    self.inner = body
  }

  var body: some HTML<HTMLTag.div> {
    div(
      .id(Self.id),
      .data("theme", value: theme.rawValue),
      .class("flex flex-col min-h-screen min-w-full justify-between")
    ) {
      main(.class("flex flex-col min-h-screen min-w-full grow mb-auto")) {
        inner
      }
    }
  }

}
