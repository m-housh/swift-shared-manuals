import Dependencies
import DependenciesTestSupport
import Elementary
import Fluent
import Foundation
import SharedModels
import SharedStyleguide
import SharedViews
import SnapshotTesting
import Testing

@Suite(
  .snapshots(record: .missing),
  .dependencies {
    $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
    $0.uuid = .incrementing
  }
)
struct ProjectViewTests {

  static var mockProject: Project {
    withDependencies {
      $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
      $0.uuid = .incrementing
    } operation: {
      Project.mock
    }
  }

  @Test(
    arguments: [Self.mockProject, nil]
  )
  func projectForm(project: Project?) {
    assertSnapshot(
      of: ProjectForm(project: project),
      as: .html,
      named: project == nil ? "nil" : "not-nil"
    )
  }

  @Test
  func table() {
    assertSnapshot(
      of:
        ProjectsTable(
          userID: .init(UUID(0)),
          projects: .init(items: [Self.mockProject], metadata: .init(page: 1, per: 25, total: 1))
        ),
      as: .html
    )
  }

  @Test
  func detail() {
    assertSnapshot(of: ProjectDetail(project: Self.mockProject), as: .html)
  }
}
