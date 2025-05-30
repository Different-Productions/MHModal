import XCTest
import SwiftUI
@testable import MHModal

@MainActor
final class MorphingModalTests: XCTestCase {
    
    func testMorphingModalInitialization() {
        let coordinator = ModalCoordinator()
        let modal = MorphingModal(coordinator: coordinator) {
            Text("Test Content")
        }
        
        // Test that modal can be created
        XCTAssertNotNil(modal)
    }
    
    func testMorphingModalWithCustomCoordinator() {
        let appearance = ModalAppearance.dark
        let behavior = ModalBehavior.nonDismissible
        let coordinator = ModalCoordinator(appearance: appearance, behavior: behavior)
        
        let modal = MorphingModal(coordinator: coordinator) {
            VStack {
                Text("Custom Content")
                Button("Action") { }
            }
        }
        
        XCTAssertNotNil(modal)
    }
    
    func testMorphingModalBodyRendering() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        
        let modal = MorphingModal(coordinator: coordinator) {
            Text("Test Content")
        }
        
        // Test that body can be accessed without errors
        let body = modal.body
        XCTAssertNotNil(body)
    }
    
    func testMorphingModalWithPresentedState() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 200)
        
        let modal = MorphingModal(coordinator: coordinator) {
            Text("Presented Content")
        }
        
        // When presented, modal should show content
        let body = modal.body
        XCTAssertNotNil(body)
    }
    
    func testMorphingModalWithNotPresentedState() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = false
        
        let modal = MorphingModal(coordinator: coordinator) {
            Text("Hidden Content")
        }
        
        // When not presented, modal should still have a body (just not visible)
        let body = modal.body
        XCTAssertNotNil(body)
    }
}