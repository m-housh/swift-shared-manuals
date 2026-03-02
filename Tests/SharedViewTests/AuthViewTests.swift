import Elementary
import SharedModels
import SharedStyleguide
import SharedViews
import SnapshotTesting
import Testing

@Suite(
  .snapshots(record: .missing)
)
struct AuthViewTests {
  @Test
  func loginForm() {
    assertSnapshot(of: LoginForm(next: "/"), as: .html)
  }

  @Test
  func signupForm() {
    assertSnapshot(of: SignupForm(), as: .html)
  }
}
