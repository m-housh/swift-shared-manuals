import Dependencies
import Elementary

extension DependencyValues {
  public var mainPage: any MainPage {
    get { self[MainPageKey.self] }
    set { self[MainPageKey.self] = newValue }
  }
}

public protocol MainPage: Sendable {
  func embed(html: AnySendableHTML) async throws -> any SendableHTMLDocument
}

enum MainPageKey: TestDependencyKey {
  static var testValue: any MainPage { UnimplementedMainPage() }
}

struct UnimplementedMainPage: MainPage {
  func embed(html: AnySendableHTML) async throws -> any SendableHTMLDocument {
    unimplemented(placeholder: UnimplementedDocument())
  }
}

struct UnimplementedDocument: SendableHTMLDocument {
  var title: String { "Unimplemented" }

  var head: some HTML {
    meta(.charset(.utf8))
    meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
  }

  var body: some HTML {
    EmptyHTML()
  }
}
