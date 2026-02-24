import CasePathsCore
import Foundation
@preconcurrency import URLRouting

public enum SharedRoute: Sendable, Routeable {
  case privacyPolicy
  case user(UserRoute)

  public static let router = OneOf {
    Route(.case(Self.privacyPolicy)) {
      Path { "privacy-policy" }
      Method.get
    }
    Route(.case(Self.user)) {
      UserRoute.router
    }
  }
}
