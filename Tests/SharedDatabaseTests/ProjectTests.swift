import Dependencies
import Fluent
import FluentSQLiteDriver
import SharedModels
import SharedTestSupport
import Testing
import Vapor

@testable import SharedDatabase

@Suite
struct ProjectTests {

  @Test
  func projectHappyPaths() async throws {
    try await withTestUser { user in
      @Dependency(\.sharedDatabase.projects) var projects

      let project = try await projects.create(
        user.id,
        Project.Create(
          name: "Testy McTestface", streetAddress: "1234 Sesame St", city: "Nowhere", state: "OH",
          zipCode: "45050")
      )

      let got = try await projects.get(project.id)
      #expect(got == project)

      let page = try await projects.fetch(user.id, .init(page: 1, per: 25))
      #expect(page.items.first! == project)

      let nextPageRequest = PageRequest.next(page)
      #expect(nextPageRequest.page == 2)
      #expect(nextPageRequest.per == 25)

      let updated = try await projects.update(
        project.id,
        .init(
          name: "Testy Updated",
          streetAddress: "12345 Sesame St",
          city: "Somewhere",
          state: "MA",
          zipCode: "55555"
        )
      )
      #expect(updated.id == project.id)
      #expect(updated.name == "Testy Updated")
      #expect(updated.streetAddress == "12345 Sesame St")
      #expect(updated.city == "Somewhere")
      #expect(updated.state == "MA")
      #expect(updated.zipCode == "55555")

      try await projects.delete(project.id)

      let shouldBeNil = try await projects.get(project.id)
      #expect(shouldBeNil == nil)

    }

  }

  @Test
  func notFound() async throws {
    try await withTestDatabase {
      @Dependency(\.sharedDatabase.projects) var projects

      await #expect(throws: NotFoundError.self) {
        try await projects.delete(.init(UUID(0)))
      }

      await #expect(throws: NotFoundError.self) {
        try await projects.update(.init(UUID(0)), .init(name: "Foo"))
      }

    }
  }

  @Test(
    arguments: [
      ProjectModel(
        name: "", streetAddress: "1234 Sesame St", city: "Nowhere", state: "OH", zipCode: "55555",
        userID: .init(UUID(0))
      ),
      ProjectModel(
        name: "Testy", streetAddress: "", city: "Nowhere", state: "OH", zipCode: "55555",
        userID: .init(UUID(0))
      ),
      ProjectModel(
        name: "Testy", streetAddress: "1234 Sesame St", city: "", state: "OH", zipCode: "55555",
        userID: .init(UUID(0))
      ),
      ProjectModel(
        name: "Testy", streetAddress: "1234 Sesame St", city: "Nowhere", state: "",
        zipCode: "55555",
        userID: .init(UUID(0))
      ),
      ProjectModel(
        name: "Testy", streetAddress: "1234 Sesame St", city: "Nowhere", state: "OH",
        zipCode: "",
        userID: .init(UUID(0))
      ),
    ]
  )
  func validations(model: ProjectModel) {
    var errors = [String]()

    #expect(throws: (any Error).self) {
      do {
        try model.validate()
      } catch {
        // Just checking to make sure I'm not testing the same error over and over /
        // making sure I've reset to good values / only testing one property at a time.
        #expect(!errors.contains("\(error)"))
        errors.append("\(error)")
        throw error
      }
    }
  }
}
