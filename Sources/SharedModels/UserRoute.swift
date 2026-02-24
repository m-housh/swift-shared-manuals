import CasePaths
import Foundation
@preconcurrency import URLRouting

// TODO: Add update password route.
public enum UserRoute: Equatable, Sendable, Routeable {
  case login(Login)
  case logout
  case profile(Profile)
  case signup(Signup)

  public static let router = OneOf {
    Route(.case(Self.login)) {
      Login.router
    }
    Route(.case(Self.logout)) {
      Path { "logout" }
      Method.get
    }
    Route(.case(Self.profile)) {
      Profile.router
    }
    Route(.case(Self.signup)) {
      Signup.router
    }
  }

  public enum Login: Equatable, Sendable {
    case index
    case submit(User.Login)

    static let path = "login"

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
            Optionally {
              Field("next", .string)
            }
          }
          .map(.memberwise(User.Login.init))
        }

      }
    }
  }

  public enum Profile: Equatable, Sendable {
    case index(User.ID)
    case submit(User.Profile.Create)
    case update(User.ID, User.Profile.Update)

    static let path = "profile"

    static let router = OneOf {
      Route(.case(Self.index)) {
        Path {
          path
          User.ID.parser()
        }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          FormData {
            Field("userID") { User.ID.parser() }
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
      Route(.case(Self.update)) {
        Path {
          path
          User.ID.parser()
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
    }
  }
}
