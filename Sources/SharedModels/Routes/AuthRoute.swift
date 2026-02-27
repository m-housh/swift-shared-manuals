import CasePaths
import Foundation
@preconcurrency import URLRouting

extension SharedRoute {
  public enum Auth: Sendable, Routeable {
    case login(Login)
    case logout

    public static let router = OneOf {
      Route(.case(Self.login)) {
        Login.router
      }
      Route(.case(Self.logout)) {
        Path { "logout" }
        Method.get
      }
    }

    public enum Login: Equatable, Sendable {
      case index(next: String? = nil)
      case submit(User.Login)

      public static func index<R: Routeable>(
        next route: R
      ) -> Self {
        .index(next: R.router.path(for: route))
      }

      static let path = "login"

      static let router = OneOf {
        Route(.case(Self.index)) {
          Path { path }
          Query {
            Optionally {
              Field("next", .string)
            }
          }
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
  }
}
