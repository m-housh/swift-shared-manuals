import Dependencies
import Foundation
import SharedModels
import Testing
import URLRouting

@Suite
struct SharedRouteTests {

  let router = SharedRoute.router

  @Test
  func privacyPolicy() throws {
    let sut = try router.match(url: URL(string: "/privacy-policy")!)
    #expect(sut == .privacyPolicy)
  }

  @Test
  func loginSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/login",
      body: .init("email=test@example.com&password=super-secret&next=/".utf8)
    )

    let route = try router.match(request: .init(data: request)!)
    let expected = User.Login(
      email: "test@example.com",
      password: "super-secret",
      next: "/"
    )
    #expect(route == .auth(.login(.submit(expected))))
  }

  @Test
  func loginIndex() throws {
    let request = URLRequestData(method: "GET", path: "/login")
    let route = try router.match(request: .init(data: request)!)
    #expect(route == .auth(.login(.index())))

    let route2 = try router.match(url: URL(string: "/login?next=foo")!)
    #expect(route2 == .auth(.login(.index(next: "foo"))))
  }

  @Test
  func logout() throws {
    let route = try router.match(url: URL(string: "/logout")!)
    #expect(route == .auth(.logout))
  }

  @Test
  func profileIndex() throws {
    let request = URLRequestData(method: "GET", path: "/user/\(UUID(0))/profile")
    let route = try router.match(request: .init(data: request)!)
    #expect(route == .user(.profile(.init(UUID(0)), .index)))
  }

  @Test
  func profileSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/signup/profile",
      body: .init(
        "userID=\(UUID(0))&firstName=Testy&lastName=McTestface&companyName=Acme%20Co.&streetAddress=1234%20Sesame%20St.&city=Nowhere&state=OH&zipCode=45050&theme=dark"
          .utf8)
    )
    let route = try router.match(request: .init(data: request)!)
    let expected = User.Profile.Create(
      userID: .init(UUID(0)),
      firstName: "Testy",
      lastName: "McTestface",
      companyName: "Acme Co.",
      streetAddress: "1234 Sesame St.",
      city: "Nowhere",
      state: "OH",
      zipCode: "45050",
      theme: .dark
    )
    #expect(route == .user(.signup(.submitProfile(expected))))
  }

  @Test
  func profileUpdate() throws {
    let request = URLRequestData(
      method: "PATCH",
      path: "/user/\(UUID(0))/profile/\(UUID(1))",
      body: .init(
        "firstName=Testy&lastName=McTestface&companyName=Acme%20Co.&streetAddress=1234%20Sesame%20St.&city=Nowhere&state=OH&zipCode=45050&theme=dark"
          .utf8)
    )
    let route = try router.match(request: .init(data: request)!)
    let expected = User.Profile.Update(
      firstName: "Testy",
      lastName: "McTestface",
      companyName: "Acme Co.",
      streetAddress: "1234 Sesame St.",
      city: "Nowhere",
      state: "OH",
      zipCode: "45050",
      theme: .dark
    )
    #expect(route == .user(.profile(.init(UUID(0)), .update(.init(UUID(1)), expected))))
  }

  @Test
  func signupIndex() throws {
    let route = try router.match(path: "/signup")
    #expect(route == .user(.signup(.index)))
  }

  @Test
  func signupSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/signup",
      body: .init("email=test@example.com&password=super-secret&confirmPassword=super-secret".utf8)
    )
    let route = try router.match(request: .init(data: request)!)
    let expected = User.Create(
      email: "test@example.com",
      password: "super-secret",
      confirmPassword: "super-secret"
    )
    #expect(route == .user(.signup(.submit(expected))))
  }
}
