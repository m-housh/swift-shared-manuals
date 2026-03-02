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
struct UserViewTests {

  static var mock: User.Profile {
    withDependencies {
      $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
      $0.uuid = .incrementing
    } operation: {
      User.Profile.mock
    }
  }

  @Test(
    arguments: [Self.mock, nil]
  )
  func form(profile: User.Profile?) {
    assertSnapshot(
      of: UserProfileForm(userID: profile?.userID ?? .init(UUID(0)), profile: profile),
      as: .html,
      named: profile == nil ? "nil" : "not-nil"
    )
  }

  @Test
  func profile() {
    assertSnapshot(of: UserProfileView(profile: Self.mock), as: .html)
  }
}
