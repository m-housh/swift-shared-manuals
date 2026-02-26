import Elementary

public struct SignupForm: HTML, Sendable, Identifiable {

  public let id = LoginForm.id

  public init() {}

  public var body: some HTML<HTMLTag.div> {
    LoginForm(style: .signup)
  }
}
