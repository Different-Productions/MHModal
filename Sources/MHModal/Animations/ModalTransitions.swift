//
//  ModalTransitions.swift
//  MHModal
//
//  Created by Michael Harrigan on 2/24/26.
//

import SwiftUI

// MARK: - Content Transition Modifiers

/// Cross-fade with subtle vertical offset + scale for in-modal content changes.
struct ModalCrossFadeModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .scaleEffect(isActive ? 1 : 0.98)
            .offset(y: isActive ? 0 : 8)
    }
}

/// Slide forward (left-to-right) for wizard flows going forward.
struct ModalSlideForwardModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive ? 0 : 30)
    }
}

/// Slide backward (right-to-left) for wizard flows going back.
struct ModalSlideBackwardModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive ? 0 : -30)
    }
}

// MARK: - Public Transitions

extension AnyTransition {

    /// Subtle cross-fade with 8pt y-offset + 0.98 scale — ideal for in-modal content changes.
    public static var modalCrossFade: AnyTransition {
        .modifier(
            active: ModalCrossFadeModifier(isActive: false),
            identity: ModalCrossFadeModifier(isActive: true)
        )
    }

    /// Horizontal slide forward (30pt) + opacity — wizard flows going forward.
    public static var modalSlideForward: AnyTransition {
        .modifier(
            active: ModalSlideForwardModifier(isActive: false),
            identity: ModalSlideForwardModifier(isActive: true)
        )
    }

    /// Horizontal slide backward (30pt) + opacity — wizard flows going back.
    public static var modalSlideBackward: AnyTransition {
        .modifier(
            active: ModalSlideBackwardModifier(isActive: false),
            identity: ModalSlideBackwardModifier(isActive: true)
        )
    }
}
