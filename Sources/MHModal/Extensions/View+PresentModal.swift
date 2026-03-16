//
//  View+PresentModal.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// Clean, modern API for presenting morphing modals.
extension View {

    /// Presents a morphing modal that automatically resizes to fit its content.
    ///
    /// This is the primary API for MHModal - it provides automatic morphing behavior
    /// with minimal configuration required. The modal will smoothly resize whenever
    /// the content changes, perfect for multi-step flows and dynamic content.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls modal presentation
    ///   - appearance: Visual appearance configuration
    ///   - behavior: Interaction behavior configuration
    ///   - animation: Animation configuration
    ///   - content: The content to display inside the modal
    ///
    /// Example:
    /// ```swift
    /// .presentModal(isPresented: $showModal) {
    ///     OnboardingFlow() // Automatically morphs as user progresses
    /// }
    /// ```
    public func presentModal<Content: View>(
        isPresented: Binding<Bool>,
        appearance: ModalAppearance = .default,
        behavior: ModalBehavior = .default,
        animation: ModalAnimation = .default,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self.modifier(
            PresentModalModifier(
                isPresented: isPresented,
                appearance: appearance,
                behavior: behavior,
                animation: animation,
                content: content
            )
        )
    }
}

// MARK: - Modal Presentation Modifier

/// ViewModifier that handles modal presentation logic
private struct PresentModalModifier<ModalContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let appearance: ModalAppearance
    let behavior: ModalBehavior
    let animation: ModalAnimation
    let modalContent: ModalContent

    @State private var coordinator: ModalCoordinator

    init(
        isPresented: Binding<Bool>,
        appearance: ModalAppearance,
        behavior: ModalBehavior,
        animation: ModalAnimation,
        @ViewBuilder content: () -> ModalContent
    ) {
        self._isPresented = isPresented
        self.appearance = appearance
        self.behavior = behavior
        self.animation = animation
        self.modalContent = content()

        self._coordinator = State(wrappedValue: ModalCoordinator(
            appearance: appearance,
            behavior: behavior,
            animation: animation
        ))
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            MorphingModal(coordinator: coordinator) {
                modalContent
            }
        }
        // Bidirectional sync: the binding drives coordinator state via present()/dismiss(),
        // and coordinator state (e.g. drag-to-dismiss) drives the binding back.
        // Both onChange guards prevent re-entrancy by comparing before writing.
        .onChange(of: isPresented) { oldValue, newValue in
            if newValue != coordinator.isPresented {
                if newValue {
                    coordinator.present()
                } else {
                    coordinator.dismiss()
                }
            }
        }
        .onChange(of: coordinator.isPresented) { oldValue, newValue in
            if newValue != isPresented {
                isPresented = newValue
            }
        }
    }
}

// MARK: - Phase-Based API

extension View {

    /// Presents a morphing modal with automatic content transitions between phases.
    ///
    /// When the `phase` value changes, the old content cross-fades out and new content
    /// fades in, while the modal height morphs smoothly. Perfect for multi-step flows.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls modal presentation
    ///   - phase: The current phase value. Changing this triggers a content transition.
    ///   - appearance: Visual appearance configuration
    ///   - behavior: Interaction behavior configuration
    ///   - animation: Animation configuration
    ///   - transition: The transition applied when the phase changes. Defaults to `.modalCrossFade`.
    ///   - content: A view builder that produces content for the given phase.
    ///
    /// Example:
    /// ```swift
    /// .presentModal(isPresented: $show, phase: currentStep) { step in
    ///     switch step {
    ///     case 0: WelcomeView()
    ///     case 1: DetailsView()
    ///     default: DoneView()
    ///     }
    /// }
    /// ```
    public func presentModal<Phase: Hashable, ModalContent: View>(
        isPresented: Binding<Bool>,
        phase: Phase,
        appearance: ModalAppearance = .default,
        behavior: ModalBehavior = .default,
        animation: ModalAnimation = .default,
        transition: AnyTransition = .modalCrossFade,
        @ViewBuilder content: @escaping (Phase) -> ModalContent
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: appearance,
            behavior: behavior,
            animation: animation
        ) {
            ModalContentTransition(
                phase: phase,
                transition: transition,
                content: content
            )
        }
    }
}

// MARK: - Convenience Modifiers

extension View {

    /// Presents a modal with minimal appearance (no drag indicator)
    public func presentMinimalModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .minimal,
            content: content
        )
    }

    /// Presents a modal with card appearance (more rounded, tighter spacing)
    public func presentCardModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .card,
            content: content
        )
    }

    /// Presents a modal with sheet appearance (edge-to-edge, matching native iOS sheets)
    public func presentSheetModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .sheet,
            content: content
        )
    }
}
