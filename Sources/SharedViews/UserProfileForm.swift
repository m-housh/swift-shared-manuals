import Elementary
import ElementaryHTMX
import SharedModels
import SharedStyleguide

// TODO: Add 'next' for to push a url after signup ??
public struct UserProfileForm: HTML, Sendable, Identifiable {

  public static func id(_ profile: User.Profile?) -> String {
    let base = "userProfileForm"
    guard let profile else { return base }
    return "\(base)_\(profile.id.idString)"
  }

  public var id: String { Self.id(profile) }

  private let userID: User.ID
  private let profile: User.Profile?
  private let signup: Bool

  public init(
    userID: User.ID,
    profile: User.Profile? = nil,
    signup: Bool = false
  ) {
    self.userID = userID
    self.profile = profile
    self.signup = signup
  }

  var route: String {
    guard !signup else {
      return UserRoute.router.path(for: .signup(.index))
        .appendingPath("profile")
    }
    return UserRoute.router.path(for: .profile(.index(userID)))
  }

  public var body: some HTML<HTMLTag.div> {
    div {

      h1(.class("text-xl font-bold pb-6")) { "Profile" }

      form(
        .class("grid grid-cols-1 gap-4 p-4"),
        profile == nil
          ? .hx.post(route)
          : .hx.patch(route),
        .hx.target(id: "content"),
        .hx.swap(.outerHTML)
      ) {
        if let profile {
          input(.class("hidden"), .name("id"), .value(profile.id))
        }
        input(.class("hidden"), .name("userID"), .value(userID))

        label(.class("input w-full")) {
          span(.class("label")) { "First Name" }
          input(.name("firstName"), .value(profile?.firstName), .required, .autofocus)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "Last Name" }
          input(.name("lastName"), .value(profile?.lastName), .required)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "Company" }
          input(.name("companyName"), .value(profile?.companyName), .required)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "Address" }
          input(.name("streetAddress"), .value(profile?.streetAddress), .required)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "City" }
          input(.name("city"), .value(profile?.city), .required)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "State" }
          input(.name("state"), .value(profile?.state), .required)
        }

        label(.class("input w-full")) {
          span(.class("label")) { "Zip" }
          input(.name("zipCode"), .value(profile?.zipCode), .required)
        }

        // Hidden theme controller.
        input(
          .class("checkbox hidden theme-controller"),
          .type(.checkbox),
          .id("theme-control"),
          .value(profile?.theme?.rawValue),
          .checked
        )

        label(.class("select w-full")) {
          span(.class("label")) { "Theme" }
          Select(
            [
              "Default": [Theme.default],
              "Light": Theme.lightThemes,
              "Dark": Theme.darkThemes,
            ],
            placeholder: "Optional theme",
            value: { $0.rawValue },
            selected: { profile?.theme == $0 },
            makeLabel: { theme in
              HTMLText(theme.rawValue.capitalized)
            }
          )
          .attributes(
            .id("theme"),
            .name("theme"),
            .on(
              .change,
              """
              (function() {
                const checkbox = document.getElementById('theme-control');
                const select = document.getElementById('theme');
                checkbox.value = select.value;
              })();
              """
            )
          )
        }

        SubmitButton()
          .attributes(.class("btn-block"))

      }
    }
  }
}
