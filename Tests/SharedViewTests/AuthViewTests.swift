import Elementary
import SharedModels
import SharedStyleguide
import SharedTestSupport
import SharedViews
import SnapshotTesting
import Testing
@preconcurrency import URLRouting

@Suite(
  .snapshots(record: .missing)
)
struct AuthViewTests {

  @Test
  func loginForm() async throws {
    assertSnapshot(of: LoginForm(next: "/"), as: .html)
  }

  @Test
  func signupForm() {
    assertSnapshot(of: SignupForm(), as: .html)
  }
}
