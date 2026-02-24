import Elementary
import ElementaryHTMX
import Foundation
import SharedMiddleware
import SharedModels

struct MyMainPage: MainPage {
  func embed(html: AnySendableHTML) async throws -> any SendableHTMLDocument {
    let htmlString = try await html.renderAsync()
    return MainPageView {
      HTMLRaw(htmlString)
    }
  }
}

public struct MainPageView<Inner: HTML>: SendableHTMLDocument where Inner: Sendable {

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

  public var head: some HTML {
    meta(.charset(.utf8))
    meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
    script(.src("https://unpkg.com/htmx.org@2.0.8")) {}
    script(.src("https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4")) {}
    HTMLRaw(
      """
      <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
      <link href="https://cdn.jsdelivr.net/npm/daisyui@5/themes.css" rel="stylesheet" type="text/css" />
      """
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

  public var body: some HTML {
    div(.class("flex flex-col min-h-screen min-w-full justify-between")) {
      main(.class("flex flex-col min-h-screen min-w-full grow mb-auto")) {
        div(.id("content")) {
          inner
        }
      }
    }
    .attributes(.data("theme", value: theme?.rawValue ?? "default"), when: theme != nil)

  }
}
