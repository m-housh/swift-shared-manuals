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
  ) async throws -> some HTML & Sendable {
    switch route {
    case .delete(let id):
      await ResultView {
        try await database.projects.delete(id)
      }
    case .detail(let id):
      await ResultView {
        guard let project = try await database.projects.get(id) else {
          throw NotFoundError()
        }
        return project
      } onSuccess: { project in
        ProjectDetail(project: project)
      }
    case .index:
      await ResultView {
        let user = try auth.currentUser()
        return (
          user.id,
          try await database.projects.fetch(user.id, .first)
        )
      } onSuccess: { userID, projects in
        ProjectsTable(userID: userID, projects: projects)
      }
    case .page(let page):
      await ResultView {
        let user = try auth.currentUser()
        return try await database.projects.fetch(user.id, page)
      } onSuccess: { projects in
        ProjectsTable.Rows(projects: projects)
      }

    case .submit(let form):
      await ResultView {
        let user = try auth.currentUser()
        let project = try await database.projects.create(user.id, form)
        return try await afterSubmit(project)
      }

    case .update(_, _):
      fatalError()
    }
  }
}
