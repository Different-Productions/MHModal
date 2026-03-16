import XCTest
@testable import MHModal

final class ModalBehaviorTests: XCTestCase {

  func testDefaultBehavior() {
    let behavior = ModalBehavior.default
    XCTAssertTrue(behavior.isDismissible)
  }

  func testNonDismissibleBehavior() {
    let behavior = ModalBehavior.nonDismissible
    XCTAssertFalse(behavior.isDismissible)
  }

  func testCustomBehavior() {
    let behavior = ModalBehavior(isDismissible: false)
    XCTAssertFalse(behavior.isDismissible)
  }

  func testEquality() {
    let a = ModalBehavior(isDismissible: false)
    let b = ModalBehavior(isDismissible: false)
    let c = ModalBehavior(isDismissible: true)

    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }
}
