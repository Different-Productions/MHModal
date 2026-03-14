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
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .default,
            behavior: .default,
            content: content
        )
    }
    
    /// Presents a morphing modal with custom appearance.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls modal presentation
    ///   - appearance: Visual appearance configuration
    ///   - content: The content to display inside the modal
    public func presentModal<Content: View>(
        isPresented: Binding<Bool>,
        appearance: ModalAppearance,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: appearance,
            behavior: .default,
            content: content
        )
    }
    
    /// Presents a morphing modal with custom behavior.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls modal presentation
    ///   - behavior: Interaction behavior configuration
    ///   - content: The content to display inside the modal
    public func presentModal<Content: View>(
        isPresented: Binding<Bool>,
        behavior: ModalBehavior,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .default,
            behavior: behavior,
            content: content
        )
    }
    
    /// Presents a morphing modal with full customization.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls modal presentation
    ///   - appearance: Visual appearance configuration
    ///   - behavior: Interaction behavior configuration
    ///   - content: The content to display inside the modal
    public func presentModal<Content: View>(
        isPresented: Binding<Bool>,
        appearance: ModalAppearance,
        behavior: ModalBehavior,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            PresentModalModifier(
                isPresented: isPresented,
                appearance: appearance,
                behavior: behavior,
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
    let content: () -> ModalContent
    
    @State private var coordinator: ModalCoordinator
    
    init(
        isPresented: Binding<Bool>,
        appearance: ModalAppearance,
        behavior: ModalBehavior,
        @ViewBuilder content: @escaping () -> ModalContent
    ) {
        self._isPresented = isPresented
        self.appearance = appearance
        self.behavior = behavior
        self.content = content
        
        // Initialize coordinator with configuration
        self._coordinator = State(wrappedValue: ModalCoordinator(
            appearance: appearance,
            behavior: behavior
        ))
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            MorphingModal(coordinator: coordinator) {
                self.content()
            }
        }
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
        transition: AnyTransition = .modalCrossFade,
        @ViewBuilder content: @escaping (Phase) -> ModalContent
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: appearance,
            behavior: behavior
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
        @ViewBuilder content: @escaping () -> Content
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
        @ViewBuilder content: @escaping () -> Content
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
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        presentModal(
            isPresented: isPresented,
            appearance: .sheet,
            content: content
        )
    }
}