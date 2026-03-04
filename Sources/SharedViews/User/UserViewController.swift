import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedModels
import SharedStyleguide
import Vapor

public struct UserViewController<Next: HTML>: ViewController where Next: Sendable {

  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database

  let afterSignup: @Sendable (User.Profile) async throws -> Next

  public init(
    @HTMLBuilder afterSignup: @escaping @Sendable (User.Profile) async throws -> Next
  ) {
    self.afterSignup = afterSignup
  }

  @HTMLBuilder
  public func view(
    for route: User.ViewRoute,
    on request: Request
  ) async throws -> (some HTML & Sendable) {
    switch route {
    case .profile(let userID, let route):
      switch route {
      case .index:
        await ResultView {
          guard let profile = try await database.userProfiles.fetch(userID) else {
            throw NotFoundError()
          }
          return profile
        } onSuccess: { profile in
          UserProfileView(profile: profile)
        }
      case .update(let id, let updates):
        await ResultView {
          try await database.userProfiles.update(id, updates)
        } onSuccess: { profile in
          UserProfileView(profile: profile)
        }
      }
    case .signup(let route):
      switch route {
      case .index:
        Modal(open: true, displayCloseButton: false) {
          SignupForm()
        }
      case .submit(let form):
        await ResultView {
          try await auth.createAndLogin(form)
        } onSuccess: { user in
          Modal(open: true, displayCloseButton: false) {
            UserProfileForm(userID: user.id, signup: true)
          }
        }
      case .submitProfile(let form):
        await ResultView {
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
