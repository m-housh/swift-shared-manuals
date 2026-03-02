import Dependencies
import DependenciesTestSupport
import Elementary
import SharedTestSupport
import SharedViews
import SnapshotTesting
import Testing

@Suite(
  .snapshots(record: .missing),
)
struct SharedViewTests {

  @Test
  func privacyPolicy() {
    assertSnapshot(of: PrivacyPolicyView(), as: .html)
  }

  @Test
  func mainDocument() {
    assertSnapshot(
      of: MainDocument(title: "Test") { HTMLText("Test") },
      as: .html,
      named: "empty-head"
    )

    assertSnapshot(
      of: MainDocument(title: "Test") {
        DefaultHead()
      } body: {
        HTMLText("Test")
      },
      as: .html,
      named: "default-head"
    )
  }
}
