import CasePaths
import Foundation
import Tagged
@preconcurrency import URLRouting

extension User {

  static let idParser = From(.utf8) {
    UUID.parser().map(.representing(User.ID.self))
  }

  // TODO: Add update password route.
  // TODO: Signup route should have a 'next' property too.
  public enum ViewRoute: Equatable, Sendable, Routeable {
    case profile(User.ID, Profile)
    case signup(Signup)

    public static let router = OneOf {
      Route(.case(Self.profile)) {
        Path {
          "user"
          User.idParser
        }
        Profile.router
      }
      Route(.case(Self.signup)) {
        Signup.router
      }
    }

    public enum Profile: Equatable, Sendable {
      case index
      case update(User.Profile.ID, User.Profile.Update)

      static let path = "profile"

      static let router = OneOf {
        Route(.case(Self.index)) {
          Path { path }
          Method.get
        }
        Route(.case(Self.update)) {
          Path {
            path
            User.Profile.idParser
          }
          Method.patch
          Body {
            FormData {
              Optionally {
                Field("firstName", .string)
              }
              Optionally {
                Field("lastName", .string)
              }
              Optionally {
                Field("companyName", .string)
              }
              Optionally {
                Field("streetAddress", .string)
              }
              Optionally {
                Field("city", .string)
              }
              Optionally {
                Field("state", .string)
              }
              Optionally {
                Field("zipCode", .string)
              }
              Optionally {
                Field("theme") { Theme.parser() }
              }
            }
            .map(.memberwise(User.Profile.Update.init))
          }
        }
      }
    }

    public enum Signup: Equatable, Sendable {
      case index
      case submit(User.Create)
      case submitProfile(User.Profile.Create)

      static let path = "signup"

      static let router = OneOf {
        Route(.case(Self.index)) {
          Path { path }
          Method.get
        }
        Route(.case(Self.submit)) {
          Path { path }
          Method.post
          Body {
            FormData {
              Field("email", .string)
              Field("password", .string)
              Field("confirmPassword", .string)
            }
            .map(.memberwise(User.Create.init))
          }
        }
        Route(.case(Self.submitProfile)) {
          Path {
            path
            "profile"
          }
          Method.post
          Body {
            FormData {
              Field("userID") { User.idParser }
              Field("firstName", .string)
              Field("lastName", .string)
              Field("companyName", .string)
              Field("streetAddress", .string)
              Field("city", .string)
              Field("state", .string)
              Field("zipCode", .string)
              Optionally {
                Field("theme") { Theme.parser() }
              }
            }
            .map(.memberwise(User.Profile.Create.init))
          }
        }
      }
    }
  }
}

extension User.Profile {
  static let idParser = From(.utf8) {
    UUID.parser().map(.representing(Self.ID.self))
  }
}
