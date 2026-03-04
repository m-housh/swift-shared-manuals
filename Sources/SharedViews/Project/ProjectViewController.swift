import AuthClient
import Dependencies
import Elementary
import SharedDatabase
import SharedModels
import SharedStyleguide
import Vapor

public struct ProjectViewController<Next: HTML>: ViewController where Next: Sendable {
  @Dependency(\.auth) var auth
  @Dependency(\.sharedDatabase) var database

  let afterSubmit: @Sendable (Project) async throws -> Next

  public init(
    @HTMLBuilder afterCreate: @escaping @Sendable (Project) async throws -> Next
  ) {
    self.afterSubmit = afterCreate
  }

  public func view(
    for route: Project.ViewRoute,
    on request: Request
  ) async throws -> ViewResponse {
    switch route {
    case .delete(let id):
      return .view {
        try await database.projects.delete(id)
      }
    case .detail(let id):
      return .view {
        guard let project = try await database.projects.get(id) else {
          throw NotFoundError()
        }

        return ProjectDetail(project: project)
      }
    case .index:
      return .view {
        let user = try auth.currentUser()
        let projects = try await database.projects.fetch(user.id, .first)
        return ProjectsTable(userID: user.id, projects: projects)
      }
    case .page(let page):
      return .view {
        let user = try auth.currentUser()
        let projects = try await database.projects.fetch(user.id, page)
        return ProjectsTable.Rows(projects: projects)
      }

    case .submit(let form):
      return .view {
        await ResultView {
          let user = try auth.currentUser()
          let project = try await database.projects.create(user.id, form)
          return try await afterSubmit(project)
        }
      }

    case .update(_, _):
      fatalError()
    }
  }
}
