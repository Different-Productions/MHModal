import XCTest
import SwiftUI
@testable import MHModal

@MainActor
final class ViewPresentModalExtensionTests: XCTestCase {

  func testPresentModalBasicAPI() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentModal(isPresented: binding) {
      Text("Content")
    }
    XCTAssertNotNil(view)
  }

  func testPresentModalWithAppearance() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentModal(
      isPresented: binding,
      appearance: .minimal
    ) {
      Text("Content")
    }
    XCTAssertNotNil(view)
  }

  func testPresentModalWithBehavior() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentModal(
      isPresented: binding,
      behavior: .nonDismissible
    ) {
      Text("Content")
    }
    XCTAssertNotNil(view)
  }

  func testPresentModalWithFullCustomization() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentModal(
      isPresented: binding,
      appearance: .minimal,
      behavior: .nonDismissible
    ) {
      VStack {
        Text("Customized")
        Button("Action") { }
      }
    }
    XCTAssertNotNil(view)
  }

  func testPresentMinimalModal() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentMinimalModal(isPresented: binding) {
      Text("Content")
    }
    XCTAssertNotNil(view)
  }

  func testPresentSheetModal() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentSheetModal(isPresented: binding) {
      Text("Content")
    }
    XCTAssertNotNil(view)
  }

  func testPresentModalWithPhase() {
    let binding = Binding<Bool>(get: { false }, set: { _ in })
    let view = Text("Base").presentModal(
      isPresented: binding,
      phase: 0
    ) { step in
      switch step {
      case 0: Text("Step 1")
      case 1: Text("Step 2")
      default: Text("Done")
      }
    }
    XCTAssertNotNil(view)
  }
}
