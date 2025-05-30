import XCTest
import SwiftUI
@testable import MHModal

@MainActor
final class ModalCoordinatorTests: XCTestCase {
    
    func testInitialization() {
        let coordinator = ModalCoordinator()
        
        XCTAssertFalse(coordinator.isPresented)
        XCTAssertEqual(coordinator.contentSize, .zero)
        XCTAssertEqual(coordinator.dragOffset, 0)
        XCTAssertEqual(coordinator.screenSize, .zero)
        XCTAssertFalse(coordinator.isMorphing)
    }
    
    func testInitializationWithCustomConfiguration() {
        let appearance = ModalAppearance.minimal
        let behavior = ModalBehavior.nonDismissible
        let coordinator = ModalCoordinator(appearance: appearance, behavior: behavior)
        
        XCTAssertEqual(coordinator.appearance, appearance)
        XCTAssertEqual(coordinator.behavior, behavior)
    }
    
    func testPresent() {
        let coordinator = ModalCoordinator()
        
        coordinator.present()
        
        XCTAssertTrue(coordinator.isPresented)
    }
    
    func testDismiss() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        coordinator.dragOffset = 50
        
        coordinator.dismiss()
        
        XCTAssertFalse(coordinator.isPresented)
        XCTAssertEqual(coordinator.dragOffset, 0)
    }
    
    func testUpdateContentSize() {
        let coordinator = ModalCoordinator()
        let newSize = CGSize(width: 300, height: 200)
        
        coordinator.updateContentSize(newSize)
        
        XCTAssertEqual(coordinator.contentSize, newSize)
        XCTAssertTrue(coordinator.isMorphing)
    }
    
    func testUpdateContentSizeIgnoresZero() {
        let coordinator = ModalCoordinator()
        coordinator.contentSize = CGSize(width: 100, height: 100)
        
        coordinator.updateContentSize(.zero)
        
        XCTAssertEqual(coordinator.contentSize, CGSize(width: 100, height: 100))
        XCTAssertFalse(coordinator.isMorphing)
    }
    
    func testUpdateContentSizeIgnoresSameSize() {
        let coordinator = ModalCoordinator()
        let size = CGSize(width: 200, height: 150)
        coordinator.contentSize = size
        
        coordinator.updateContentSize(size)
        
        XCTAssertFalse(coordinator.isMorphing)
    }
    
    func testUpdateScreenSize() {
        let coordinator = ModalCoordinator()
        let screenSize = CGSize(width: 375, height: 812)
        
        coordinator.updateScreenSize(screenSize)
        
        XCTAssertEqual(coordinator.screenSize, screenSize)
    }
    
    func testModalHeightCalculation() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 200)
        
        let expectedHeight = 200 + coordinator.topPadding + coordinator.bottomPadding
        XCTAssertEqual(coordinator.modalHeight, expectedHeight)
    }
    
    func testModalHeightWithMaxHeightConstraint() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 800) // Very tall content
        
        let maxHeight = coordinator.screenSize.height * coordinator.appearance.maxHeightRatio
        XCTAssertEqual(coordinator.modalHeight, maxHeight)
    }
    
    func testModalHeightWithMinHeightConstraint() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 10) // Very small content
        
        XCTAssertEqual(coordinator.modalHeight, 100) // Minimum height
    }
    
    func testTopPaddingWithDragIndicator() {
        let coordinator = ModalCoordinator(appearance: ModalAppearance(showDragIndicator: true))
        
        XCTAssertEqual(coordinator.topPadding, 36)
    }
    
    func testTopPaddingWithoutDragIndicator() {
        let coordinator = ModalCoordinator(appearance: ModalAppearance(showDragIndicator: false))
        
        XCTAssertEqual(coordinator.topPadding, 16)
    }
    
    func testShouldScroll() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        // Set content size that would exceed max modal height
        let maxHeight = coordinator.screenSize.height * coordinator.appearance.maxHeightRatio
        coordinator.contentSize = CGSize(width: 300, height: maxHeight) // Content that fills max height
        
        XCTAssertTrue(coordinator.shouldScroll)
    }
    
    func testShouldNotScroll() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 100) // Small content
        
        XCTAssertFalse(coordinator.shouldScroll)
    }
    
    func testUpdateDragOffset() {
        let coordinator = ModalCoordinator()
        
        coordinator.updateDragOffset(50)
        
        XCTAssertEqual(coordinator.dragOffset, 50)
    }
    
    func testHandleDragEndWithDismiss() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        
        // Large translation should dismiss
        coordinator.handleDragEnd(translation: 150, velocity: 50)
        
        XCTAssertFalse(coordinator.isPresented)
    }
    
    func testHandleDragEndWithHighVelocity() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        
        // High velocity should dismiss
        coordinator.handleDragEnd(translation: 50, velocity: 200)
        
        XCTAssertFalse(coordinator.isPresented)
    }
    
    func testHandleDragEndWithoutDismiss() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        coordinator.dragOffset = 50
        
        // Small translation and velocity should not dismiss
        coordinator.handleDragEnd(translation: 30, velocity: 50)
        
        XCTAssertTrue(coordinator.isPresented)
        // Note: dragOffset reset happens with animation, so we can't easily test it
    }
    
    func testHandleDragEndWhenDragDisabled() {
        let coordinator = ModalCoordinator(behavior: ModalBehavior(enableDragToDismiss: false))
        coordinator.isPresented = true
        
        // Even large translation shouldn't dismiss when drag is disabled
        coordinator.handleDragEnd(translation: 200, velocity: 300)
        
        XCTAssertTrue(coordinator.isPresented)
    }
    
    func testConvenienceInitializers() {
        let minimalCoordinator = ModalCoordinator.minimal()
        XCTAssertEqual(minimalCoordinator.appearance, .minimal)
        
        let cardCoordinator = ModalCoordinator.card()
        XCTAssertEqual(cardCoordinator.appearance, .card)
    }
}
