import XCTest
import SwiftUI
@testable import MHModal

final class ModalAppearanceTests: XCTestCase {

  func testDefaultAppearance() {
    let appearance = ModalAppearance.default

    XCTAssertEqual(appearance.background, Color(.systemBackground))
    XCTAssertTrue(appearance.showGrabber)
    XCTAssertNil(appearance.cornerRadius)
    XCTAssertNil(appearance.maxHeightRatio)
    XCTAssertTrue(appearance.dimBackground)
  }

  func testMinimalAppearance() {
    let appearance = ModalAppearance.minimal

    XCTAssertFalse(appearance.showGrabber)
    XCTAssertEqual(appearance.cornerRadius, 24)
  }

  func testSheetAppearance() {
    XCTAssertEqual(ModalAppearance.sheet, ModalAppearance.default)
  }

  func testCustomAppearance() {
    let appearance = ModalAppearance(
      background: .blue,
      showGrabber: false,
      cornerRadius: 20,
      maxHeightRatio: 0.75,
      dimBackground: false
    )

    XCTAssertEqual(appearance.background, .blue)
    XCTAssertFalse(appearance.showGrabber)
    XCTAssertEqual(appearance.cornerRadius, 20)
    XCTAssertEqual(appearance.maxHeightRatio, 0.75)
    XCTAssertFalse(appearance.dimBackground)
  }

  func testMaxHeightRatioClamping() {
    let tooHigh = ModalAppearance(maxHeightRatio: 1.5)
    XCTAssertEqual(tooHigh.maxHeightRatio, 1.0)

    let negative = ModalAppearance(maxHeightRatio: -0.5)
    XCTAssertEqual(negative.maxHeightRatio, 0.0)

    let valid = ModalAppearance(maxHeightRatio: 0.75)
    XCTAssertEqual(valid.maxHeightRatio, 0.75)

    let nilRatio = ModalAppearance()
    XCTAssertNil(nilRatio.maxHeightRatio)
  }

  func testEquality() {
    let a = ModalAppearance(background: .blue, cornerRadius: 20)
    let b = ModalAppearance(background: .blue, cornerRadius: 20)
    let c = ModalAppearance(background: .red, cornerRadius: 20)

    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }
}
