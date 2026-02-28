import CasePathsCore
import Fluent
import Foundation
import Tagged
@preconcurrency import URLRouting

// TODO: Make the router a dependency, can use the current router
//       as the default live router.

public enum SharedRoute: Sendable, Equatable, Routeable {
  case auth(Auth)
  case privacyPolicy
  case project(Project.ViewRoute)
  case user(User.ViewRoute)

  public static let router = OneOf {
    Route(.case(Self.auth)) {
      Auth.router
    }
    Route(.case(Self.privacyPolicy)) {
      Path { "privacy-policy" }
      Method.get
    }
    Route(.case(Self.project)) {
      Project.ViewRoute.router
    }
    Route(.case(Self.user)) {
      User.ViewRoute.router
    }
  }

}
