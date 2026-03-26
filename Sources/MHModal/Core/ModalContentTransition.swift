//
//  ModalContentTransition.swift
//  MHModal
//
//  Created by Michael Harrigan on 2/24/26.
//

import SwiftUI

/// A container for phase-based modal content.
///
/// Transitions between phases are handled by the UIKit presenter using a
/// synchronized cross-dissolve + sheet height morph (the DPWhatsNew pattern).
/// SwiftUI's `.id(phase)` ensures the view hierarchy is recreated on phase changes.
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
    private let content: (Phase) -> Content

    /// Creates a phase-based content transition container.
    /// - Parameters:
    ///   - phase: The current phase value. Changing this triggers a transition.
    ///   - content: A view builder that produces content for the given phase.
    public init(
        phase: Phase,
        @ViewBuilder content: @escaping (Phase) -> Content
    ) {
        self.phase = phase
        self.content = content
    }

    public var body: some View {
        content(phase)
            .id(phase)
    }
}
