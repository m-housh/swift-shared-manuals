import Dependencies
import Elementary
import ElementaryHTMX
import Foundation
import HTMLSnapshotTesting
import SharedModels
import SharedViews
import SnapshotTesting
import Testing
@preconcurrency import URLRouting

@Suite(
  .snapshots(record: .missing)
)
struct SharedViewTests {

  @Test
  func dateView() {
    let date = Date(timeIntervalSince1970: 1_234_567_890)
    let view = DateView(date)

    assertSnapshot(of: view, as: .html)
  }

  @Test
  func numberView() {
    let double = NumberView(20.99945, digits: 3)
    assertSnapshot(of: double, as: .html)

    let int = NumberView(Int(10))
    assertSnapshot(of: int, as: .html)
  }

  @Test
  func inputValue() {
    assertSnapshot(of: input(.value(12.1)), as: .html)
    assertSnapshot(of: input(.value(69)), as: .html)
    assertSnapshot(of: input(.value(UUID(0))), as: .html)
    assertSnapshot(of: input(.value(String?.none)), as: .html)
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

  /// NOTE: Doesn't work if using the patterns as test arguments.
  @Test
  func inputPattern() {
    assertSnapshot(of: input(.pattern(.username)), as: .html)
    assertSnapshot(of: input(.pattern(.password)), as: .html)
  }

  @Test
  func tooltip() {
    for position in AnchorPosition.allCases {
      let sut = button { "Test" }
        .tooltip("I'm a tooltip", position: position)
      assertSnapshot(of: sut, as: .html)
    }
  }

  @Test
  func svg() {
    assertSnapshot(of: SVG.close, as: .html)
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
}

struct TestError: Error {

  var localizedDescription: String {
    "This is only a test!"
  }
}
