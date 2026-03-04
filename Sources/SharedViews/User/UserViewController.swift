import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedModels
import SharedStyleguide
import Vapor

// TODO: Remove after signup and redirect / use next route in signup form.
public struct UserViewController<Next: HTML>: ViewController where Next: Sendable {

  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database

  let afterSignup: @Sendable (User.Profile) async throws -> Next

  public init(
    @HTMLBuilder afterSignup: @escaping @Sendable (User.Profile) async throws -> Next
  ) {
    self.afterSignup = afterSignup
  }

  public func view(
    for route: User.ViewRoute,
    on request: Request
  ) async throws -> ViewResponse {
    switch route {
    case .profile(let userID, let route):
      switch route {
      case .index:
        return .view {
          guard let profile = try await database.userProfiles.fetch(userID) else {
            throw NotFoundError()
          }
          return UserProfileView(profile: profile)
        }
      case .update(let id, let updates):
        return .view {
          let profile = try await database.userProfiles.update(id, updates)
          return UserProfileView(profile: profile)
        }
      }
    case .signup(let route):
      switch route {
      case .index:
        return .view {
          Modal(open: true, displayCloseButton: false) {
            SignupForm()
          }
        }
      case .submit(let form):
        return .view {
          let user = try await auth.createAndLogin(form)
          return Modal(open: true, displayCloseButton: false) {
            UserProfileForm(userID: user.id, signup: true)
          }
        }
      case .submitProfile(let form):
        return .view {
          let profile = try await database.userProfiles.create(form)
          return try await afterSignup(profile)
        }
      }
    }
  }
}

extension UserViewController where Next == UserProfileView {
  public init() {
    self.init { profile in
      UserProfileView(profile: profile)
    }
  }
}
