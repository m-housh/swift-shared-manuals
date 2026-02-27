import Elementary
import SharedModels

public struct MainDocument<Content: HTML, Head: HTML>: HTMLDocument {

  public let title: String
  public let lang: String

  let inner: Content
  let theme: Theme?
  let _head: Head

  public init(
    title: String,
    language: String = "en",
    theme: Theme? = nil,
    @HTMLBuilder head: () -> Head,
    @HTMLBuilder body: () -> Content
  ) {
    self.title = title
    self.lang = language
    self.theme = theme
    self._head = head()
    self.inner = body()
  }

  public var head: some HTML {
    meta(.charset(.utf8))
    meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
    _head
  }

  public var body: some HTML {
    MainContent(theme: theme) {
      inner
    }
  }
}

extension MainDocument: Sendable where Head: Sendable, Content: Sendable {}

extension MainDocument where Head == EmptyHTML {

  public init(
    title: String,
    language: String = "en",
    theme: Theme? = nil,
    @HTMLBuilder body: () -> Content
  ) {
    self.init(
      title: title,
      language: language,
      theme: theme,
      head: { EmptyHTML() },
      body: body
    )
  }
}

public struct DefaultHead<Head: HTML>: HTML {

  private let extraHead: Head
  private let useDaisyUI: Bool
  private let useTailwind: Bool

  public init(
    withDaisyUI useDaisyUI: Bool = true,
    withTailwind useTailwind: Bool = true,
    @HTMLBuilder head: () -> Head
  ) {
    self.useDaisyUI = useDaisyUI
    self.useTailwind = useTailwind
    self.extraHead = head()
  }

  public var body: some HTML {
    script(.src("https://unpkg.com/htmx.org@2.0.8")) {}
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
    if useDaisyUI {
      link(
        .href("https://cdn.jsdelivr.net/npm/daisyui@5"), .rel(.stylesheet),
        .init(name: "type", value: "text/css"))
      link(
        .href("https://cdn.jsdelivr.net/npm/daisyui@5/themes.css"), .rel(.stylesheet),
        .init(name: "type", value: "text/css"))
    }
    if useTailwind {
      script(.src("https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4")) {}
    }
    extraHead
  }
}
extension DefaultHead: Sendable where Head: Sendable {}

extension DefaultHead where Head == EmptyHTML {
  public init() {
    self.init { EmptyHTML() }
  }
}
