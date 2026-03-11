//
//  ModalPresentationModifiers.swift
//  MHModal
//
//  Created by Michael Harrigan on 2/24/26.
//

import SwiftUI

// MARK: - AnyTransition Helpers

extension AnyTransition {
    /// Modal slides up from below the screen edge.
    static var modalPresent: AnyTransition {
        .move(edge: .bottom)
    }

    /// Modal slides back down off the screen edge.
    static var modalDismiss: AnyTransition {
        .move(edge: .bottom)
    }
}
