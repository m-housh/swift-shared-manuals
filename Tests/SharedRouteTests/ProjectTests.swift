import Dependencies
import Foundation
import SharedModels
import Testing
import URLRouting

@Suite
struct ProjectRouteTests {
  let router = SharedRoute.router

  @Test
  func delete() throws {
    let request = URLRequestData(method: "DELETE", path: "/projects/\(UUID(0))")
    let sut = try router.match(request: .init(data: request)!)
    #expect(sut == .project(.delete(.init(UUID(0)))))
  }

  @Test
  func detail() throws {
    let request = URLRequestData(method: "GET", path: "/projects/\(UUID(0))")
    let sut = try router.match(request: .init(data: request)!)
    #expect(sut == .project(.detail(.init(UUID(0)))))
  }

  @Test
  func index() throws {
    let sut = try router.match(url: URL(string: "/projects")!)
    #expect(sut == .project(.index))
  }

  @Test
  func page() throws {
    let sut = try router.match(url: URL(string: "/projects/page?page=1&per=25")!)
    #expect(sut == .project(.page(.init(page: 1, per: 25))))
  }

  @Test
  func submit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/projects",
      body: .init(
        "name=Test&streetAddress=123%20Sesame%20St&city=Manhattan&state=NY&zipCode=10001"
          .utf8)
    )
    let sut = try router.match(request: .init(data: request)!)
    let expected = Project.Create.init(
      name: "Test",
      streetAddress: "123 Sesame St",
      city: "Manhattan",
      state: "NY",
      zipCode: "10001"
    )
    #expect(sut == .project(.submit(expected)))
  }

  @Test
  func update() throws {
    let request = URLRequestData(
      method: "PATCH",
      path: "/projects/\(UUID(0))",
      body: .init(
        "name=Test&streetAddress=123%20Sesame%20St&city=Manhattan&state=NY&zipCode=10001"
          .utf8)
    )
    let sut = try router.match(request: .init(data: request)!)
    let expected = Project.Update(
      name: "Test",
      streetAddress: "123 Sesame St",
      city: "Manhattan",
      state: "NY",
      zipCode: "10001"
    )
    #expect(sut == .project(.update(.init(UUID(0)), expected)))
  }
}
