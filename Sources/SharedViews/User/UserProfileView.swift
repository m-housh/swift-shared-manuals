import Elementary
import SharedModels
import SharedStyleguide

public struct UserProfileView: HTML, Sendable {
  let profile: User.Profile

  public init(profile: User.Profile) {
    self.profile = profile
  }

  public var body: some HTML<HTMLTag.div> {
    div {
      PageTitleRow {
        PageTitle { "Account" }

        Button(
          .class("btn-primary"),
          .showModal(id: UserProfileForm.id(profile)),
          svg: .squarePen
        )
        .tooltip("Edit profile", position: .left)
      }

      table(.class("table table-zebra")) {
        tr {
          td { span(.class("label font-bold")) { "Name" } }
          td { "\(profile.firstName) \(profile.lastName)" }
        }
        tr {
          td { span(.class("label font-bold")) { "Company" } }
          td { profile.companyName }
        }
        tr {
          td { span(.class("label font-bold")) { "Street Address" } }
          td { profile.streetAddress }
        }
        tr {
          td { span(.class("label font-bold")) { "City" } }
          td { profile.city }
        }
        tr {
          td { span(.class("label font-bold")) { "State" } }
          td { profile.state }
        }
        tr {
          td { span(.class("label font-bold")) { "Zip Code" } }
          td { profile.zipCode }
        }
        tr {
          td { span(.class("label font-bold")) { "Theme" } }
          td { profile.theme?.rawValue ?? "" }
        }

      }

      Modal {
        UserProfileForm(userID: profile.userID, profile: profile)
      }
    }
  }
}
