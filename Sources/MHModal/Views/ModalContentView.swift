//
//  ModalContentView.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI
import UIKit

/// The content container view for the modal.
extension ModalView {
  /// Main modal content view
  @ViewBuilder
  var modalContentView: some View {
    VStack(spacing: 0) {
      // Optional drag indicator
      if appearance.showDragIndicator {
        dragIndicatorView
      }
      
      // Content with automatic scrolling if needed
      if contentSize.height > modalHeight - topPadding - 20 {
        ScrollView {
          content
          // Add padding to ensure content doesn't touch edges
            .padding(.bottom, 8)
          // Place the size reader outside the content but inside the ScrollView
          // This ensures we can measure the full content height
            .background(sizeReaderView)
        }
        .scrollIndicators(.hidden)
        // Also track the total scroll content size with a separate size reader
        .background(
          GeometryReader { fullScrollProxy in
            Color.clear
              .preference(key: SizePreferenceKey.self, value: fullScrollProxy.size)
              .onPreferenceChange(SizePreferenceKey.self) { [contentSize] fullScrollSize in
                // For ScrollView content, simply update the size whenever it changes
                // This ensures we always track the actual full content height
                if fullScrollSize.height > 0 && fullScrollSize != contentSize {
                  Task { @MainActor in
                    self.contentSize = fullScrollSize
                    self.animateModalResize()
                  }
                }
              }
          }
        )
      } else {
        content
          .background(sizeReaderView)
        // Add padding to ensure content doesn't touch edges
          .padding(.bottom, 8)
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: modalHeight)
    .background(appearance.background)
    .clipShape(RoundedRectangle(cornerRadius: appearance.cornerRadius, style: .continuous))
    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -2)
    .padding(.horizontal, appearance.horizontalPadding)
    .padding(.bottom, appearance.bottomPadding)
    .offset(y: dragOffset - keyboardHeight)
    .animation(dragAnimation, value: dragOffset)
    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: keyboardHeight)
    .gesture(behavior.enableDragToDismiss ? dragGesture : nil)
    .transition(modalTransition)
    // Apply a more specific animation for height changes
    .animation(appearance.sizeChangeAnimation, value: modalHeight)
    // Monitor keyboard notifications
    .onAppear {
      setupKeyboardObservers()
    }
    .onDisappear {
      // Clean up observers when view disappears
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
  }
  
  /// Drag indicator pill at top of modal
  @ViewBuilder
  var dragIndicatorView: some View {
    RoundedRectangle(cornerRadius: 2.5)
      .fill(appearance.dragIndicatorColor)
      .frame(width: 36, height: 5)
      .padding(.top, 12)
      .padding(.bottom, 20)
  }
}
