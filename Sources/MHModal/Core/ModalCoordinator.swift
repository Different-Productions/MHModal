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
@Observable
public final class ModalCoordinator {
    
    // MARK: - Core State
    
    /// Whether the modal is currently presented
    public var isPresented: Bool = false
    
    /// Current size of the modal content
    public var contentSize: CGSize = .zero
    
    /// Current drag offset for gesture interactions
    public var dragOffset: CGFloat = 0
    
    /// Screen dimensions for calculations
    public var screenSize: CGSize = .zero
    
    // MARK: - Animation State
    
    /// Whether a morphing animation is currently in progress
    public var isMorphing: Bool = false
    
    /// Previous content size for smooth transitions
    private var previousContentSize: CGSize = .zero
    
    // MARK: - Configuration
    
    /// Visual appearance configuration
    public let appearance: ModalAppearance
    
    /// Interaction behavior configuration
    public let behavior: ModalBehavior
    
    // MARK: - Animation Configuration
    
    /// Animation used for morphing transitions
    public var morphAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
    
    /// Animation used for drag gestures
    public var dragAnimation: Animation {
        .interactiveSpring(response: 0.3, dampingFraction: 0.7)
    }
    
    /// Animation used for present/dismiss
    public var presentAnimation: Animation {
        .spring(response: 0.5, dampingFraction: 0.8)
    }
    
    // MARK: - Initialization
    
    /// Creates a new modal coordinator with the specified configuration
    /// - Parameters:
    ///   - appearance: Visual appearance settings
    ///   - behavior: Interaction behavior settings
    public init(
        appearance: ModalAppearance = .default,
        behavior: ModalBehavior = .default
    ) {
        self.appearance = appearance
        self.behavior = behavior
    }
    
    // MARK: - Core Modal Operations
    
    /// Presents the modal with animation
    public func present() {
        withAnimation(presentAnimation) {
            isPresented = true
        }
    }
    
    /// Dismisses the modal with animation
    public func dismiss() {
        withAnimation(presentAnimation) {
            isPresented = false
            dragOffset = 0
        }
    }
    
    // MARK: - Size Management (Core Morphing Logic)
    
    /// Updates the content size and triggers morphing animation
    /// This is the core of our morphing behavior - always smooth, always responsive
    /// - Parameter newSize: The new content size
    public func updateContentSize(_ newSize: CGSize) {
        // Skip if size hasn't actually changed
        guard newSize != contentSize && newSize != .zero else { return }
        
        // Store previous size for potential future use
        previousContentSize = contentSize
        
        // Always morph - this is our core behavior
        withAnimation(morphAnimation) {
            isMorphing = true
            contentSize = newSize
        }
        
        // Reset morphing flag after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        
        let maxHeight = screenSize.height * appearance.maxHeightRatio
        let minHeight: CGFloat = 100
        
        // Content height plus padding for drag indicator if shown
        let totalContentHeight = contentSize.height + topPadding + bottomPadding
        
        return min(max(totalContentHeight, minHeight), maxHeight)
    }
    
    /// Top padding (includes drag indicator space)
    public var topPadding: CGFloat {
        appearance.showDragIndicator ? 36 : 16
    }
    
    /// Bottom padding for content
    public var bottomPadding: CGFloat {
        16
    }
    
    /// Whether content should scroll (exceeds available space)
    public var shouldScroll: Bool {
        contentSize.height > (modalHeight - topPadding - bottomPadding)
    }
    
    // MARK: - Gesture Support
    
    /// Updates drag offset during gesture
    /// - Parameter offset: Current drag offset
    public func updateDragOffset(_ offset: CGFloat) {
        dragOffset = offset
    }
    
    /// Handles end of drag gesture, determining whether to dismiss
    /// - Parameters:
    ///   - translation: Final translation of the drag
    ///   - velocity: Velocity of the drag gesture
    public func handleDragEnd(translation: CGFloat, velocity: CGFloat) {
        let shouldDismiss = translation > behavior.dismissDistanceThreshold ||
                           velocity > behavior.dismissVelocityThreshold
        
        if shouldDismiss && behavior.enableDragToDismiss {
            dismiss()
        } else {
            // Return to original position
            withAnimation(dragAnimation) {
                dragOffset = 0
            }
        }
    }
}

// MARK: - Convenience Extensions

extension ModalCoordinator {
    /// Creates a coordinator with light appearance
    public static func light() -> ModalCoordinator {
        ModalCoordinator(appearance: .light)
    }
    
    /// Creates a coordinator with dark appearance
    public static func dark() -> ModalCoordinator {
        ModalCoordinator(appearance: .dark)
    }
    
    /// Creates a coordinator with minimal appearance
    public static func minimal() -> ModalCoordinator {
        ModalCoordinator(appearance: .minimal)
    }
}