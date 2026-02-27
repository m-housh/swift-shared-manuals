import Elementary
import ElementaryHTMX
import SharedModels
import SharedStyleguide
import SharedViews

struct PageView<Content: HTML>: HTML, Sendable where Content: Sendable {
  let _body: Content

  init(@HTMLBuilder body: () -> Content) {
    self._body = body()
  }

  public var body: some HTML<HTMLTag.div> {
    div(.class("mx-10 mt-6")) {
      _body
    }
  }
}

struct LoggedIn: HTML, Sendable {
  let next: String

  init(next: String?) {
    self.next = next ?? SiteRoute.router.path(for: .home)
  }

  var body: some HTML {
    div(
      .class("flex justify-center items-center mx-auto my-auto"),
      .hx.get(next),
      .hx.pushURL(true),
      .hx.target("#content"),
      .hx.swap(.innerHTML.swap("1s")),
      .hx.trigger(.event(.revealed)),
      .hx.indicator()
    ) {
      Indicator(size: .xl)
    }
  }
}

struct HomePage: HTML, Sendable {
  let user: User?

  var body: some HTML {
    div(.class("flex mt-10 justify-center items-center")) {
      if let user {
        div(.class("space-y-4")) {
          h1(.class("text-3xl font-bold")) { "Welcome \(user.email)." }
          div(.class("flex space-x-4 justify-center")) {
            button(
              .class("btn btn-primary"),
              .hx.get(route: SiteRoute.shared(.auth(.logout))),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
            ) {
              "Logout"
            }
            button(
              .class("btn btn-secondary"),
              .hx.get(route: SiteRoute.user(.profile(user.id, .index))),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
              .hx.pushURL(true)
            ) {
              "Profile"
            }
            button(
              .class("btn btn-accent"),
              .hx.get(route: SiteRoute.project(.index)),
              .hx.target(id: "content"),
              .hx.swap(.innerHTML),
              .hx.pushURL(true)
            ) {
              "Projects"
            }
          }
        }
      } else {
        Modal(open: true, displayCloseButton: false) {
          LoginForm()
        }
      }
    }
  }
}
