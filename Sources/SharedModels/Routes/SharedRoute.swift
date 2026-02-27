import CasePathsCore
import Foundation
@preconcurrency import URLRouting

public enum SharedRoute: Sendable, Routeable {
  case privacyPolicy
  case project(Project.ViewRoute)
  case user(User.ViewRoute)

  public static let router = OneOf {
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
