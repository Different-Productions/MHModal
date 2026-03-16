//
//  ModalCoordinator.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// Central coordinator for managing modal state with automatic morphing behavior.
///
/// `ModalCoordinator` is the single source of truth for all modal state and behavior.
/// It automatically handles content size changes, animations, and user interactions
/// with a focus on smooth morphing transitions.
@MainActor
@Observable
public final class ModalCoordinator {

    // MARK: - Core State

    /// Whether the modal is currently presented
    public internal(set) var isPresented: Bool = false

    /// Current size of the modal content
    public internal(set) var contentSize: CGSize = .zero

    /// Current drag offset for gesture interactions
    public internal(set) var dragOffset: CGFloat = 0

    /// Screen dimensions for calculations
    public internal(set) var screenSize: CGSize = .zero

    // MARK: - Animation State

    /// Whether a morphing animation is currently in progress
    public internal(set) var isMorphing: Bool = false

    /// Previous content size for smooth transitions
    private var previousContentSize: CGSize = .zero

    /// Task that resets `isMorphing` after the animation settles
    private var morphResetTask: Task<Void, Never>?

    // MARK: - Accessibility

    /// Whether reduced motion is preferred (synced from SwiftUI environment)
    internal var reduceMotion: Bool = false

    // MARK: - Keyboard

    /// Keyboard observer for tracking keyboard visibility
    internal let keyboardObserver = KeyboardObserver()

    /// Current keyboard height (0 when hidden)
    public var keyboardHeight: CGFloat {
        keyboardObserver.keyboardHeight
    }

    // MARK: - Configuration

    /// Visual appearance configuration
    public let appearance: ModalAppearance

    /// Interaction behavior configuration
    public let behavior: ModalBehavior

    /// Animation configuration
    public let animation: ModalAnimation

    /// Clock used for timed operations (injectable for testing)
    @ObservationIgnored
    internal var clock: any Clock<Duration> = ContinuousClock()

    /// Resolved animation respecting accessibility reduce-motion preference
    var effectiveAnimation: ModalAnimation {
        reduceMotion ? .reduced : animation
    }

    // MARK: - Initialization

    /// Creates a new modal coordinator with the specified configuration
    /// - Parameters:
    ///   - appearance: Visual appearance settings
    ///   - behavior: Interaction behavior settings
    ///   - animation: Animation configuration
    public init(
        appearance: ModalAppearance = .default,
        behavior: ModalBehavior = .default,
        animation: ModalAnimation = .default
    ) {
        self.appearance = appearance
        self.behavior = behavior
        self.animation = animation
    }

    // MARK: - Core Modal Operations

    /// Presents the modal with animation
    public func present() {
        withAnimation(effectiveAnimation.present) {
            isPresented = true
        }
    }

    /// Dismisses the modal with animation
    public func dismiss() {
        withAnimation(effectiveAnimation.dismiss) {
            isPresented = false
            dragOffset = 0
        }
    }

    // MARK: - Size Management (Core Morphing Logic)

    /// Updates the content size and triggers morphing animation
    /// - Parameter newSize: The new content size
    public func updateContentSize(_ newSize: CGSize) {
        guard newSize != contentSize && newSize != .zero else { return }

        previousContentSize = contentSize

        withAnimation(effectiveAnimation.morph) {
            isMorphing = true
            contentSize = newSize
        }

        morphResetTask?.cancel()
        morphResetTask = Task { @MainActor in
            try? await clock.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self.isMorphing = false
        }
    }

    /// Updates screen size for layout calculations
    /// - Parameter size: Current screen size
    public func updateScreenSize(_ size: CGSize) {
        guard size != screenSize else { return }
        screenSize = size
    }

    // MARK: - Computed Properties

    /// Calculated modal height based on content and constraints
    public var modalHeight: CGFloat {
        guard screenSize.height > 0 else { return 200 }

        let minHeight: CGFloat = 100
        let maxHeight = screenSize.height * appearance.maxHeightRatio
        let totalContentHeight = contentSize.height + topPadding

        if keyboardHeight > 0 {
            let topMargin: CGFloat = 44
            let availableHeight = screenSize.height - keyboardHeight - appearance.bottomPadding - topMargin
            return max(min(totalContentHeight, min(availableHeight, maxHeight)), minHeight)
        }

        return max(min(totalContentHeight, maxHeight), minHeight)
    }

    /// Top padding (includes drag indicator space)
    public var topPadding: CGFloat {
        appearance.showsDragIndicator ? 36 : 16
    }

    /// Whether content exceeds the maximum modal height and needs SDK-level scrolling.
    /// When false, the SDK's ScrollView is disabled so user-provided scrollable
    /// content (List, ScrollView, etc.) can handle its own scrolling without nesting.
    public var contentNeedsScroll: Bool {
        guard screenSize.height > 0 else { return false }
        let maxHeight = screenSize.height * appearance.maxHeightRatio
        return contentSize.height + topPadding > maxHeight
    }

    // MARK: - Gesture Support

    /// Converts a raw drag translation into a visual offset with resistance applied
    /// - Parameter translation: Raw vertical translation from the drag gesture
    /// - Returns: Visual offset with resistance curves applied
    func dragOffset(for translation: CGFloat) -> CGFloat {
        if translation < 0 {
            // Upward: smoother resistance curve
            return -pow(abs(translation), 0.7) * 1.2
        } else {
            // Downward: progressive resistance (easy start, harder at end)
            return pow(translation, 0.85) * 1.5
        }
    }

    /// Updates drag offset during gesture
    /// - Parameter offset: Current drag offset
    public func updateDragOffset(_ offset: CGFloat) {
        dragOffset = offset
    }

    /// Completes a drag gesture, determining whether to dismiss or snap back
    /// - Parameters:
    ///   - translation: Final translation of the drag
    ///   - velocity: Velocity of the drag gesture
    public func completeDrag(translation: CGFloat, velocity: CGFloat) {
        let shouldDismiss = translation > behavior.dismissDistanceThreshold ||
                           velocity > behavior.dismissVelocityThreshold

        if shouldDismiss && behavior.isDragToDismissEnabled {
            dismiss()
        } else {
            withAnimation(effectiveAnimation.drag) {
                dragOffset = 0
            }
        }
    }
}

// MARK: - Convenience Extensions

extension ModalCoordinator {
    /// Creates a coordinator with minimal appearance
    public static func makeMinimal() -> ModalCoordinator {
        ModalCoordinator(appearance: .minimal)
    }

    /// Creates a coordinator with card appearance
    public static func makeCard() -> ModalCoordinator {
        ModalCoordinator(appearance: .card)
    }
}
