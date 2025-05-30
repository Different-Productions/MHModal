//
//  SizeDetector.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// A single, efficient size detection system for modal content.
///
/// This replaces the previous complex system of multiple GeometryReaders and
/// preference keys with a clean, performant approach that feeds directly into
/// our ModalCoordinator.
struct SizeDetector: View {
    let coordinator: ModalCoordinator
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ContentSizePreferenceKey.self, value: geometry.size)
        }
        .onPreferenceChange(ContentSizePreferenceKey.self) { size in
            coordinator.updateContentSize(size)
        }
    }
}

/// A simple, efficient preference key for content size
private struct ContentSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/// Screen size detector for modal layout calculations
struct ScreenSizeDetector: View {
    let coordinator: ModalCoordinator
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ScreenSizePreferenceKey.self, value: geometry.size)
        }
        .onPreferenceChange(ScreenSizePreferenceKey.self) { size in
            coordinator.updateScreenSize(size)
        }
    }
}

/// Preference key for screen size detection
private struct ScreenSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}