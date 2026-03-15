//
//  KeyboardObserver.swift
//  MHModal
//
//  Created by Michael Harrigan on 2/24/26.
//

import SwiftUI

/// Holds the keyboard overlap value, updated by `KeyboardOverlapUIView`.
@MainActor
@Observable
final class KeyboardObserver {
    /// How many points of the tracked view the keyboard actually covers (0 when hidden).
    var keyboardHeight: CGFloat = 0
}

// MARK: - UIKit Keyboard Tracking

#if canImport(UIKit)
import UIKit

/// A UIView placed in the hierarchy that converts the keyboard frame to local
/// coordinates via `convert(_:from:)`, giving the exact overlap with its own bounds.
/// Only updates on keyboard notifications — never in `layoutSubviews` — to avoid
/// feedback loops with SwiftUI's layout engine.
final class KeyboardOverlapUIView: UIView {

    weak var observer: KeyboardObserver?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Notification Handlers

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              bounds.height > 0 else { return }

        let localFrame = convert(frame, from: nil)
        let overlap = max(bounds.height - localFrame.origin.y, 0)
        MainActor.assumeIsolated {
            observer?.keyboardHeight = overlap
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        MainActor.assumeIsolated {
            observer?.keyboardHeight = 0
        }
    }
}

/// SwiftUI bridge — place as `.background()` so the UIView matches the parent's bounds.
struct KeyboardOverlapReader: UIViewRepresentable {

    let observer: KeyboardObserver

    func makeUIView(context: Context) -> KeyboardOverlapUIView {
        let view = KeyboardOverlapUIView()
        view.observer = observer
        return view
    }

    func updateUIView(_ uiView: KeyboardOverlapUIView, context: Context) {
        uiView.observer = observer
    }
}
#endif
