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

  private let authViewController: Auth
  private let projectViewController: Projects
  private let userViewController: Users

  public init(
    auth authViewController: Auth,
    projects projectViewController: Projects,
    users userViewController: Users
  ) {
    self.authViewController = authViewController
    self.projectViewController = projectViewController
    self.userViewController = userViewController
  }

  public func view(
    for route: SharedRoute,
    on request: Request
  ) async throws -> ViewResponse {
    switch route {
    case .auth(let route):
      return try await authViewController.view(for: route, on: request)
    case .privacyPolicy:
      return .view {
        PrivacyPolicyView()
      }
    case .project(let route):
      return try await projectViewController.view(for: route, on: request)
    case .user(let route):
      return try await userViewController.view(for: route, on: request)
    }
  }
}

extension SharedViewController where Auth == AuthViewController {
  public init(
    projects projectViewController: Projects,
    users userViewController: Users
  ) {
    self.init(auth: .init(), projects: projectViewController, users: userViewController)
  }
}
