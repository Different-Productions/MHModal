//
//  MorphingModal.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// A modern modal that automatically morphs to fit its content.
///
/// `MorphingModal` is the core view component that provides smooth, automatic
/// resizing behavior based on content changes. It works with `ModalCoordinator`
/// to provide a clean, performant modal experience.
public struct MorphingModal<Content: View>: View {

    // MARK: - Properties

    let coordinator: ModalCoordinator
    let content: Content

    // MARK: - Initialization

    /// Creates a new morphing modal
    /// - Parameters:
    ///   - coordinator: The modal coordinator managing state
    ///   - content: The content to display inside the modal
    public init(
        coordinator: ModalCoordinator,
        @ViewBuilder content: () -> Content
    ) {
        self.coordinator = coordinator
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            if coordinator.isPresented {
                // Background overlay — dims *before* modal arrives
                overlayView

                // Modal content - always anchored to bottom, keyboard-aware
                modalContentView
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(ScreenSizeDetector(coordinator: coordinator))
        #if canImport(UIKit)
        .background(KeyboardOverlapReader(observer: coordinator.keyboardObserver))
        #endif
    }

    // MARK: - Drag-Responsive Computed Properties

    /// Normalised drag progress 0…1 (0 = at rest, 1 = at dismissal threshold).
    private var dragProgress: Double {
        guard coordinator.dragOffset > 0 else { return 0 }
        return min(Double(coordinator.dragOffset) / 300.0, 1.0)
    }

    /// Scale shrinks from 1.0 → 0.96 during drag — modal "shrinks away", anchored at bottom.
    private var dragScale: CGFloat {
        1.0 - (0.04 * dragProgress)
    }

    /// Corner radius grows +6pt during drag — transforms from "docked sheet" to "floating card".
    private var dragCornerRadius: CGFloat {
        coordinator.appearance.cornerRadius + (6.0 * dragProgress)
    }

    /// Shadow radius deepens from 10 → 20 during drag — modal feels "lifted off surface".
    private var dragShadowRadius: CGFloat {
        10 + (10 * dragProgress)
    }

    /// Shadow opacity deepens from 0.15 → 0.25 during drag.
    private var dragShadowOpacity: Double {
        0.15 + (0.10 * dragProgress)
    }

    /// Drag indicator width widens from 36 → 44pt when grabbed.
    private var dragIndicatorWidth: CGFloat {
        36 + (8 * dragProgress)
    }

    /// Drag indicator height thickens 1.3x when grabbed.
    private var dragIndicatorHeight: CGFloat {
        5 * (1.0 + 0.3 * dragProgress)
    }

    // MARK: - Overlay

    private var overlayView: some View {
        coordinator.appearance.overlayColor
            .opacity(overlayOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                if coordinator.keyboardHeight > 0 {
                    #if canImport(UIKit)
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                    #endif
                } else if coordinator.behavior.tapToDismiss {
                    coordinator.dismiss()
                }
            }
            .transition(.opacity.animation(.easeOut(duration: 0.25)))
    }

    /// Calculated overlay opacity based on drag state — ease-out curve for faster initial response.
    private var overlayOpacity: Double {
        let baseOpacity = 0.35
        // Quadratic ease-out: faster initial response during drag
        let easedProgress = 1.0 - pow(1.0 - dragProgress, 2)
        return baseOpacity * (1.0 - easedProgress)
    }

    // MARK: - Modal Content

    private var modalContentView: some View {
        VStack(spacing: 0) {
            // Drag indicator
            if coordinator.appearance.showDragIndicator {
                dragIndicator
            }

            // Content container
            contentContainer
        }
        .frame(height: coordinator.modalHeight)
        .frame(maxWidth: .infinity)
        .background(coordinator.appearance.background)
        .contentTransition(.interpolate)
        .clipShape(
            RoundedRectangle(
                cornerRadius: dragCornerRadius,
                style: .continuous
            )
        )
        .shadow(color: .black.opacity(dragShadowOpacity), radius: dragShadowRadius, x: 0, y: -2)
        .scaleEffect(dragScale, anchor: .bottom)
        .padding(.horizontal, coordinator.appearance.horizontalPadding)
        .padding(.bottom, coordinator.appearance.bottomPadding + coordinator.keyboardHeight)
        .offset(y: coordinator.dragOffset)
        .gesture(dragGesture)
        .transition(modalTransition)
        .animation(coordinator.dragAnimation, value: coordinator.dragOffset)
        .animation(coordinator.morphAnimation, value: coordinator.modalHeight)
        .animation(coordinator.keyboardAnimation, value: coordinator.keyboardHeight)
    }

    // MARK: - Drag Indicator

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(coordinator.appearance.dragIndicatorColor)
            .frame(width: dragIndicatorWidth, height: dragIndicatorHeight)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .animation(coordinator.dragAnimation, value: dragProgress)
    }

    // MARK: - Content Container

    private var contentContainer: some View {
        ScrollView {
            contentWithSizeDetection
                .padding(.bottom, coordinator.bottomPadding + coordinator.keyboardHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .animation(coordinator.keyboardAnimation, value: coordinator.keyboardHeight)
    }

    /// Content with size detection attached
    private var contentWithSizeDetection: some View {
        content
            .background(SizeDetector(coordinator: coordinator))
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if coordinator.behavior.enableDragToDismiss {
                    let translation = value.translation.height
                    let offset: CGFloat
                    if translation < 0 {
                        // Upward: smoother resistance curve
                        let t = abs(translation)
                        offset = -pow(t, 0.7) * 1.2
                    } else {
                        // Downward: progressive resistance (easy start, harder at end)
                        let t = translation
                        offset = pow(t, 0.85) * 1.5
                    }
                    coordinator.updateDragOffset(offset)
                }
            }
            .onEnded { value in
                if coordinator.behavior.enableDragToDismiss {
                    let velocity = value.predictedEndLocation.y - value.location.y
                    coordinator.handleDragEnd(
                        translation: value.translation.height,
                        velocity: velocity
                    )
                }
            }
    }

    // MARK: - Transitions

    private var modalTransition: AnyTransition {
        .asymmetric(
            insertion: .modalPresent
                .animation(coordinator.presentAnimation),
            removal: .modalDismiss
                .animation(coordinator.dismissAnimation)
        )
    }
}
