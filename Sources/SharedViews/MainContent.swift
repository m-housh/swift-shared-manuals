import Elementary
import SharedModels

public struct MainContent<Inner: HTML>: HTML {
  static var id: String { "content" }

  private let theme: Theme
  private let inner: Inner

  public init(theme: Theme? = nil, @HTMLBuilder body: () -> Inner) {
    self.theme = theme ?? .default
    self.inner = body()
  }

  public var body: some HTML<HTMLTag.div> {
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

extension MainContent: Sendable where Inner: Sendable {}
