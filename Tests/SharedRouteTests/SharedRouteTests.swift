import Dependencies
import Foundation
import SharedModels
import Testing
import URLRouting

@Suite
struct SharedRouteTests {

  @Test
  func loginSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/login",
      body: .init("email=test@example.com&password=super-secret&next=/".utf8)
    )

    let route = try UserRoute.router.match(request: .init(data: request)!)
    let expected = User.Login(
      email: "test@example.com",
      password: "super-secret",
      next: "/"
    )
    #expect(route == .login(.submit(expected)))
  }

  @Test
  func loginIndex() throws {
    let request = URLRequestData(method: "GET", path: "/login")
    let route = try UserRoute.router.match(request: .init(data: request)!)
    #expect(route == .login(.index))
  }

  @Test
  func logout() throws {
    let route = try UserRoute.router.match(url: URL(string: "/logout")!)
    #expect(route == .logout)
  }

  @Test
  func profileIndex() throws {
    let request = URLRequestData(method: "GET", path: "/profile/\(UUID(0))")
    let route = try UserRoute.router.match(request: .init(data: request)!)
    #expect(route == .profile(.index(UUID(0))))
  }

  @Test
  func profileSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/profile",
      body: .init(
        "userID=\(UUID(0))&firstName=Testy&lastName=McTestface&companyName=Acme%20Co.&streetAddress=1234%20Sesame%20St.&city=Nowhere&state=OH&zipCode=45050&theme=dark"
          .utf8)
    )
    let route = try UserRoute.router.match(request: .init(data: request)!)
    let expected = User.Profile.Create(
      userID: UUID(0),
      firstName: "Testy",
      lastName: "McTestface",
      companyName: "Acme Co.",
      streetAddress: "1234 Sesame St.",
      city: "Nowhere",
      state: "OH",
      zipCode: "45050",
      theme: .dark
    )
    #expect(route == .profile(.submit(expected)))
  }

  @Test
  func profileUpdate() throws {
    let request = URLRequestData(
      method: "PATCH",
      path: "/profile/\(UUID(0))",
      body: .init(
        "firstName=Testy&lastName=McTestface&companyName=Acme%20Co.&streetAddress=1234%20Sesame%20St.&city=Nowhere&state=OH&zipCode=45050&theme=dark"
          .utf8)
    )
    let route = try UserRoute.router.match(request: .init(data: request)!)
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
    #expect(route == .profile(.update(UUID(0), expected)))
  }

  @Test
  func signupIndex() throws {
    let route = try UserRoute.router.match(path: "/signup")
    #expect(route == .signup(.index))
  }

  @Test
  func signupSubmit() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/signup",
      body: .init("email=test@example.com&password=super-secret&confirmPassword=super-secret".utf8)
    )
    let route = try UserRoute.router.match(request: .init(data: request)!)
    let expected = User.Create(
      email: "test@example.com",
      password: "super-secret",
      confirmPassword: "super-secret"
    )
    #expect(route == .signup(.submit(expected)))
  }
}
