//
//  ModalContentTransition.swift
//  MHModal
//
//  Created by Michael Harrigan on 2/24/26.
//

import SwiftUI

/// A container that automatically applies cross-fade transitions when a phase value changes.
///
/// Use this view to wrap modal content that transitions between distinct phases (e.g., onboarding steps).
/// When the `phase` value changes, the old content fades out and new content fades in with a smooth
/// animation, while the modal height morphs automatically.
///
/// ```swift
/// ModalContentTransition(phase: currentStep) { step in
///     switch step {
///     case 0: WelcomeView()
///     case 1: PermissionsView()
///     default: CompletionView()
///     }
/// }
/// ```
public struct ModalContentTransition<Phase: Hashable, Content: View>: View {

    private let phase: Phase
    private let transition: AnyTransition
    private let content: (Phase) -> Content

    /// Creates a phase-based content transition container.
    /// - Parameters:
    ///   - phase: The current phase value. Changing this triggers a transition.
    ///   - transition: The transition to apply when the phase changes. Defaults to `.modalCrossFade`.
    ///   - content: A view builder that produces content for the given phase.
    public init(
        phase: Phase,
        transition: AnyTransition = .modalCrossFade,
        @ViewBuilder content: @escaping (Phase) -> Content
    ) {
        self.phase = phase
        self.transition = transition
        self.content = content
    }

    public var body: some View {
        content(phase)
            .id(phase)
            .transition(transition)
            .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.1), value: phase)
    }
}
