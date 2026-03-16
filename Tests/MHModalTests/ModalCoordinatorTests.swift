import Testing
import SwiftUI
@testable import MHModal

/// A clock that returns immediately from sleep, for deterministic testing.
struct ImmediateClock: Clock {
    typealias Duration = Swift.Duration
    typealias Instant = ContinuousClock.Instant

    var now: Instant { ContinuousClock().now }
    var minimumResolution: Duration { .zero }

    func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        // Return immediately
    }
}

@MainActor
struct ModalCoordinatorTests {

    // MARK: - Initialization

    @Test func defaultInitialization() {
        let coordinator = ModalCoordinator()

        #expect(coordinator.isPresented == false)
        #expect(coordinator.contentSize == .zero)
        #expect(coordinator.dragOffset == 0)
        #expect(coordinator.screenSize == .zero)
        #expect(coordinator.isMorphing == false)
    }

    @Test func customConfigurationInitialization() {
        let appearance = ModalAppearance.minimal
        let behavior = ModalBehavior.nonDismissible
        let coordinator = ModalCoordinator(appearance: appearance, behavior: behavior)

        #expect(coordinator.appearance == appearance)
        #expect(coordinator.behavior == behavior)
    }

    // MARK: - Present / Dismiss

    @Test func present() {
        let coordinator = ModalCoordinator()

        coordinator.present()

        #expect(coordinator.isPresented == true)
    }

    @Test func dismiss() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        coordinator.dragOffset = 50

        coordinator.dismiss()

        #expect(coordinator.isPresented == false)
        #expect(coordinator.dragOffset == 0)
    }

    // MARK: - Content Size

    @Test func updateContentSize() {
        let coordinator = ModalCoordinator()
        let newSize = CGSize(width: 300, height: 200)

        coordinator.updateContentSize(newSize)

        #expect(coordinator.contentSize == newSize)
        #expect(coordinator.isMorphing == true)
    }

    @Test func updateContentSizeIgnoresZero() {
        let coordinator = ModalCoordinator()
        coordinator.contentSize = CGSize(width: 100, height: 100)

        coordinator.updateContentSize(.zero)

        #expect(coordinator.contentSize == CGSize(width: 100, height: 100))
        #expect(coordinator.isMorphing == false)
    }

    @Test func updateContentSizeIgnoresSameSize() {
        let coordinator = ModalCoordinator()
        let size = CGSize(width: 200, height: 150)
        coordinator.contentSize = size

        coordinator.updateContentSize(size)

        #expect(coordinator.isMorphing == false)
    }

    @Test func morphResetCompletesAfterDelay() async {
        let coordinator = ModalCoordinator()
        coordinator.clock = ImmediateClock()

        coordinator.updateContentSize(CGSize(width: 300, height: 200))
        #expect(coordinator.isMorphing == true)

        // Let the morph reset task execute (ImmediateClock returns from sleep instantly)
        await Task.yield()
        await Task.yield()

        #expect(coordinator.isMorphing == false)
    }

    // MARK: - Screen Size

    @Test func updateScreenSize() {
        let coordinator = ModalCoordinator()
        let screenSize = CGSize(width: 375, height: 812)

        coordinator.updateScreenSize(screenSize)

        #expect(coordinator.screenSize == screenSize)
    }

    @Test func updateScreenSizeIgnoresSameSize() {
        let coordinator = ModalCoordinator()
        let screenSize = CGSize(width: 375, height: 812)
        coordinator.screenSize = screenSize

        coordinator.updateScreenSize(screenSize)

        #expect(coordinator.screenSize == screenSize, "Screen size should remain unchanged")
    }

    // MARK: - Modal Height

    @Test func modalHeightCalculation() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 200)

        let expectedHeight = 200 + coordinator.topPadding
        #expect(coordinator.modalHeight == expectedHeight)
    }

    @Test func modalHeightCappedByMaxHeightRatio() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 800)

        let maxHeight = coordinator.screenSize.height * coordinator.appearance.maxHeightRatio
        #expect(coordinator.modalHeight == maxHeight)
    }

    @Test func modalHeightFloorsAtMinimum() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 10)

        #expect(coordinator.modalHeight == 100, "Minimum modal height should be 100")
    }

    @Test func modalHeightFallbackWhenScreenSizeIsZero() {
        let coordinator = ModalCoordinator()

        #expect(coordinator.modalHeight == 200, "Should return 200 when screen size is zero")
    }

    // MARK: - Padding

    @Test func topPaddingWithDragIndicator() {
        let coordinator = ModalCoordinator(appearance: ModalAppearance(showsDragIndicator: true))

        #expect(coordinator.topPadding == 36)
    }

    @Test func topPaddingWithoutDragIndicator() {
        let coordinator = ModalCoordinator(appearance: ModalAppearance(showsDragIndicator: false))

        #expect(coordinator.topPadding == 16)
    }

    // MARK: - Content Needs Scroll

    @Test func contentNeedsScrollWhenExceedingMaxHeight() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        let maxHeight = coordinator.screenSize.height * coordinator.appearance.maxHeightRatio
        coordinator.contentSize = CGSize(width: 300, height: maxHeight)

        #expect(coordinator.contentNeedsScroll == true)
    }

    @Test func contentDoesNotNeedScrollForSmallContent() {
        let coordinator = ModalCoordinator()
        coordinator.screenSize = CGSize(width: 375, height: 812)
        coordinator.contentSize = CGSize(width: 300, height: 100)

        #expect(coordinator.contentNeedsScroll == false)
    }

    @Test func contentNeedsScrollReturnsFalseWhenScreenSizeIsZero() {
        let coordinator = ModalCoordinator()
        coordinator.contentSize = CGSize(width: 300, height: 1000)

        #expect(coordinator.contentNeedsScroll == false, "Should return false when screen size is zero")
    }

    // MARK: - Drag Gesture

    @Test func updateDragOffset() {
        let coordinator = ModalCoordinator()

        coordinator.updateDragOffset(50)

        #expect(coordinator.dragOffset == 50)
    }

    @Test func dragOffsetAppliesDownwardResistance() {
        let coordinator = ModalCoordinator()

        let offset = coordinator.dragOffset(for: 100)

        #expect(offset > 0)
        #expect(offset < 100, "Downward drag should apply resistance")
    }

    @Test func dragOffsetAppliesUpwardResistance() {
        let coordinator = ModalCoordinator()

        let offset = coordinator.dragOffset(for: -100)

        #expect(offset < 0)
        #expect(offset > -100, "Upward drag should apply stronger resistance")
    }

    @Test func dragOffsetIsZeroForZeroTranslation() {
        let coordinator = ModalCoordinator()

        let offset = coordinator.dragOffset(for: 0)

        #expect(offset == 0)
    }

    @Test(arguments: [
        (translation: 150.0, velocity: 50.0, dragEnabled: true, expectedDismissed: true),
        (translation: 50.0, velocity: 200.0, dragEnabled: true, expectedDismissed: true),
        (translation: 30.0, velocity: 50.0, dragEnabled: true, expectedDismissed: false),
        (translation: 200.0, velocity: 300.0, dragEnabled: false, expectedDismissed: false),
        (translation: 0.0, velocity: 0.0, dragEnabled: true, expectedDismissed: false),
    ])
    func completeDrag(
        translation: Double,
        velocity: Double,
        dragEnabled: Bool,
        expectedDismissed: Bool
    ) {
        let behavior = ModalBehavior(isDragToDismissEnabled: dragEnabled)
        let coordinator = ModalCoordinator(behavior: behavior)
        coordinator.isPresented = true

        coordinator.completeDrag(translation: translation, velocity: velocity)

        #expect(coordinator.isPresented != expectedDismissed, "translation=\(translation), velocity=\(velocity), dragEnabled=\(dragEnabled)")
    }

    @Test func completeDragResetsDragOffsetWhenNotDismissed() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true
        coordinator.dragOffset = 50

        coordinator.completeDrag(translation: 30, velocity: 50)

        #expect(coordinator.isPresented == true)
        // dragOffset is reset inside withAnimation, so value is set synchronously
        #expect(coordinator.dragOffset == 0, "Drag offset should reset when not dismissed")
    }

    // MARK: - Effective Animation

    @Test func effectiveAnimationRespectsReduceMotion() {
        let coordinator = ModalCoordinator()

        coordinator.reduceMotion = false
        let standard = coordinator.effectiveAnimation
        #expect(standard.morph == coordinator.animation.morph)

        coordinator.reduceMotion = true
        let reduced = coordinator.effectiveAnimation
        #expect(reduced.morph == ModalAnimation.reduced.morph)
    }

    // MARK: - Convenience Initializers

    @Test func makeMinimalConvenience() {
        let coordinator = ModalCoordinator.makeMinimal()
        #expect(coordinator.appearance == .minimal)
    }

    @Test func makeCardConvenience() {
        let coordinator = ModalCoordinator.makeCard()
        #expect(coordinator.appearance == .card)
    }

    // MARK: - Keyboard Height

    @Test func keyboardHeightDefaultsToZero() {
        let coordinator = ModalCoordinator()

        #expect(coordinator.keyboardHeight == 0)
    }
}
