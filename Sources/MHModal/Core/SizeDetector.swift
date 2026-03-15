//
//  SizeDetector.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// Efficient size detection for modal content using `onGeometryChange`.
struct SizeDetector: ViewModifier {
    let coordinator: ModalCoordinator

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            coordinator.updateContentSize(size)
        }
    }
}

/// Screen size detector for modal layout calculations.
struct ScreenSizeDetector: ViewModifier {
    let coordinator: ModalCoordinator

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            coordinator.updateScreenSize(size)
        }
    }
}
