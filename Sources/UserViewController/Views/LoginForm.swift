import Elementary
import ElementaryHTMX
import SharedModels
import SharedViews

struct LoginForm: HTML, Sendable {

  let style: Style
  let next: String?

  init(style: Style = .login, next: String? = nil) {
    self.style = style
    self.next = next
  }

  private var route: UserRoute {
    if style == .login {
      return .login(.index(next: next))
    }
    return .signup(.index)
  }

  private var signupRoute: UserRoute {
    if style == .signup {
      return .login(.index(next: next))
    }
    return .signup(.index)
  }

  var body: some HTML {
    Modal(id: "loginForm", open: true, displayCloseButton: false) {
      div(.class("flex justify-between")) {
        h1(.class("text-2xl font-bold mb-6")) { style.title }
        a(
          .class("btn btn-link"),
          .href(route: SharedRoute.privacyPolicy),
          .target(.blank)
        ) {
          "Privacy Policy"
        }
      }

      form(
        .method(.post),
        .class("space-y-4")
      ) {

        if let next {
          input(.class("hidden"), .name("next"), .value(next), .id("next"))
        }

        div {
          label(.class("input validator w-full")) {
            SVG.email
            input(
              .type(.email), .placeholder("Email"), .required,
              .name("email"), .id("email"), .autofocus,
              .autocomplete("email")
            )
          }
          div(.class("validator-hint hidden")) { "Enter valid email address." }
        }

        div {
          label(.class("input validator w-full")) {
            SVG.key
            input(
              .type(.password), .placeholder("Password"), .required,
              .pattern(.password), .minlength(8),
              .name("password"), .id("password"),
              .autocomplete(style == .login ? "current-password" : "new-password")
            )
          }
        }

        if style == .signup {
          div {
            label(.class("input validator w-full")) {
              SVG.key
              input(
                .type(.password), .placeholder("Confirm Password"), .required,
                .pattern(.password), .minlength(8),
                .name("confirmPassword"), .id("confirmPassword"),
                .autocomplete("new-password")
              )
            }
          }

          div(.class("validator-hint hidden")) {
            p {
              "Must be more than 8 characters, including"
              br()
              "At least one number"
              br()
              "At least one lowercase letter"
              br()
              "At least one uppercase letter"
            }
          }

        }

        div(.class("flex")) {
          button(.class("btn btn-secondary mt-4 w-full")) { style.title }
        }

        div(.class("flex justify-center")) {
          a(
            .class("btn btn-link"),
            .hx.get(route: signupRoute),
            .hx.target("#loginForm"),
            .hx.swap(.outerHTML),
            .hx.pushURL(true)
          ) {
            style == .login ? "Sign Up" : "Login"
          }
        }
      }
    }
  }
}

extension LoginForm {
  enum Style: Equatable, Sendable {
    case login
    case signup

    var title: String {
      switch self {
      case .login: return "Login"
      case .signup: return "Sign Up"
      }
    }
  }
}
