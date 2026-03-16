import XCTest
import SwiftUI
@testable import MHModal

@MainActor
final class ModalCoordinatorTests: XCTestCase {

  func testInitialization() {
    let coordinator = ModalCoordinator()

    XCTAssertFalse(coordinator.isPresented)
    XCTAssertEqual(coordinator.appearance, .default)
    XCTAssertEqual(coordinator.behavior, .default)
  }

  func testCustomConfiguration() {
    let coordinator = ModalCoordinator(
      appearance: .minimal,
      behavior: .nonDismissible
    )

    XCTAssertEqual(coordinator.appearance, .minimal)
    XCTAssertEqual(coordinator.behavior, .nonDismissible)
  }

  func testPresent() {
    let coordinator = ModalCoordinator()
    coordinator.present()
    XCTAssertTrue(coordinator.isPresented)
  }

  func testDismiss() {
    let coordinator = ModalCoordinator()
    coordinator.isPresented = true
    coordinator.dismiss()
    XCTAssertFalse(coordinator.isPresented)
  }
}
