import Dependencies
import DependenciesTestSupport
import Elementary
import ElementaryHTMX
import Foundation
import SharedStyleguide
import SharedTestSupport
import SnapshotTesting
import Testing
@preconcurrency import URLRouting

@testable import SharedModels

@Suite(
  .snapshots(record: .missing),
  .dependencies {
    $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
  }
)
struct SharedStyleguideTests {

  @Test
  func dateView() {
    @Dependency(\.date.now) var now
    assertSnapshot(of: DateView(now), as: .html)
  }

  @Test
  func numberView() {
    let double = NumberView(20.99945, digits: 3)
    assertSnapshot(of: double, as: .html)

    let int = NumberView(Int(10))
    assertSnapshot(of: int, as: .html)
  }

  @Test(arguments: TestValueInput.allCases)
  func inputValue(value: TestValueInput) {
    assertSnapshot(
      of: TestValueInputView(value: value),
      as: .html,
      named: value.name
    )
  }

  @Test
  func inputMax() {
    assertSnapshot(of: input(.max(420.69)), as: .html)
    assertSnapshot(of: input(.max(69)), as: .html)
    assertSnapshot(of: input(.max("420")), as: .html)
  }

  @Test
  func inputMin() {
    assertSnapshot(of: input(.min(420.69)), as: .html)
    assertSnapshot(of: input(.min(69)), as: .html)
    assertSnapshot(of: input(.min("420")), as: .html)
  }

  @Test
  func inputStep() {
    assertSnapshot(of: input(.step(420.69)), as: .html)
    assertSnapshot(of: input(.step(69)), as: .html)
  }

  @Test
  func inputMinLength() {
    assertSnapshot(of: input(.minlength(8)), as: .html)
  }

  @Test(arguments: PatternType.allCases)
  func inputPattern(pattern: PatternType) {
    assertSnapshot(
      of: input(.pattern(pattern)),
      as: .html,
      named: pattern.rawValue
    )
  }

  @Test(arguments: AnchorPosition.allCases)
  func tooltip(position: AnchorPosition) {
    let sut = button { "Test" }
      .tooltip("I'm a tooltip", position: position)

    assertSnapshot(of: sut, as: .html, named: "tooltip_\(position.rawValue)")
  }

  @Test
  func svg() {
    assertSnapshot(of: SVG(.close), as: .html)
  }

  @Test
  func modal() {
    var sut = Modal(id: "Test") {
      p {
        "Test content."
      }
    }
    assertSnapshot(of: sut, as: .html)

    sut = Modal(id: "Test", displayCloseButton: false) {
      p {
        "Test content."
      }
    }
    assertSnapshot(of: sut, as: .html)

    sut = Modal(id: "Test", open: true, displayCloseButton: false) {
      p {
        "Test content."
      }
    }
    assertSnapshot(of: sut, as: .html)
  }

  @Test
  func showModal() {
    let sut = button(.showModal(id: "test")) { "Open" }
    assertSnapshot(of: sut, as: .html)
  }

  @Test
  func routing() {

    func testRoute(route: TestRoute) {
      let sut = button { "Test" }
        .attributes(.hx.delete(route: route), when: route == .delete)
        .attributes(.hx.get(route: route), when: route == .get)
        .attributes(.hx.patch(route: route), when: route == .patch)
        .attributes(.hx.post(route: route), when: route == .post)
        .attributes(.hx.put(route: route), when: route == .put)
      assertSnapshot(of: sut, as: .html)
    }

    enum TestRoute: String, CaseIterable, Routeable {
      case delete
      case get
      case patch
      case post
      case put

      static let router = OneOf {
        Route(.case(Self.delete)) {
          Path { "delete" }
          Method.delete
        }
        Route(.case(Self.get)) {
          Path { "get" }
          Method.get
        }
        Route(.case(Self.patch)) {
          Path { "patch" }
          Method.patch
        }
        Route(.case(Self.post)) {
          Path { "post" }
          Method.post
        }
        Route(.case(Self.put)) {
          Path { "put" }
          Method.put
        }
      }

    }

    for route in TestRoute.allCases {
      testRoute(route: route)
    }

    // Test href attribute.
    let sut = a(.href(route: TestRoute.get)) { "Test" }
    assertSnapshot(of: sut, as: .html)
  }

  @Test
  func select() {
    enum TestValues: String, CaseIterable {
      case one
      case two
      case three
    }

    let sut = Select(
      TestValues.allCases,
      placeholder: "Test",
      value: { $0.rawValue },
      selected: { $0 == .two },
      label: \.rawValue
    )

    assertSnapshot(of: sut, as: .html)

  }

  @Test
  func resultView() async {

    let sut1 = await ResultView {
      69
    } onSuccess: {
      NumberView($0)
    }
    assertSnapshot(of: sut1, as: .html)

    let sut2 = await ResultView {
      throw TestError()
    } onSuccess: {
      NumberView($0)
    }
    assertSnapshot(of: sut2, as: .html)

    let sut3 = await ResultView {
      NumberView(420)
    }
    assertSnapshot(of: sut3, as: .html)

    let sut4 = await ResultView {
      throw TestError()
    }
    assertSnapshot(of: sut4, as: .html)
  }

  @Test
  func indicator() {
    assertSnapshot(of: Indicator(), as: .html)
  }

  @Test
  func row() {
    assertSnapshot(
      of: Row {
        HTMLText("Left")
        HTMLText("Right")
      },
      as: .html
    )
  }
}

struct TestError: Error {

  var localizedDescription: String {
    "This is only a test!"
  }
}

enum TestValueInput: CaseIterable {
  case double(Double)
  case int(Int)
  case uuid(UUID)
  case none

  static let allCases: [Self] = [
    .double(420.69),
    .int(42),
    .uuid(UUID(0)),
    .none,
  ]

  var name: String {
    switch self {
    case .double: return "double"
    case .int: return "int"
    case .uuid: return "uuid"
    case .none: return "nil"
    }
  }
}

struct TestValueInputView: HTML {
  let value: TestValueInput

  var body: some HTML {
    switch value {
    case .double(let double):
      input(.value(double))
    case .int(let int):
      input(.value(int))
    case .uuid(let uuid):
      input(.value(uuid))
    case .none:
      input(.value(String?.none))
    }
  }
}
