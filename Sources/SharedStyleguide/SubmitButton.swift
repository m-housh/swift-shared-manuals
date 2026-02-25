import Elementary

public struct SubmitButton: HTML, Sendable {
  private let title: String

  public init(title: String = "Submit") {
    self.title = title
  }

  public var body: some HTML<HTMLTag.button> {
    button(.class("btn btn-secondary"), .type(.submit)) {
      title
    }
  }
}
