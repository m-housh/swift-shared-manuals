import Dependencies
import Elementary
import SharedModels
import SharedStyleguide
import Vapor

public struct SharedViewController<Auth, Projects, Users>: ViewController
where
  Auth: ViewController<SharedRoute.Auth>,
  Projects: ViewController<Project.ViewRoute>,
  Users: ViewController<User.ViewRoute>
{

  let authViewController: Auth
  let projectViewController: Projects
  let userViewController: Users

  public init(
    authViewController: Auth,
    projectViewController: Projects,
    userViewController: Users
  ) {
    self.authViewController = authViewController
    self.projectViewController = projectViewController
    self.userViewController = userViewController
  }

  @HTMLBuilder
  public func view(
    for route: SharedRoute,
    on request: Request
  ) async throws -> some HTML & Sendable {
    switch route {
    case .auth(let route):
      await ResultView {
        try await authViewController.view(for: route, on: request)
      }
    case .privacyPolicy:
      PrivacyPolicyView()
    case .project(let route):
      try await projectViewController.view(for: route, on: request)
    case .user(let route):
      try await userViewController.view(for: route, on: request)
    }
  }
}
