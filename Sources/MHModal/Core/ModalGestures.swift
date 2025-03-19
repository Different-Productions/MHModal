//
//  ModalGestures.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI
import UIKit

/// Gesture handling for the modal view.
extension ModalView {
  // MARK: - Gestures and Animations

  /// Gesture for modal dragging and dismissal
  var dragGesture: some Gesture {
    DragGesture()
      .updating($isDragging) { _, state, _ in
        state = true
      }
      .onChanged { value in
        dragOffset = calculateDragOffset(value.translation.height)
      }
      .onEnded { value in
        handleDragEnd(value)
      }
  }

  /// Calculates how far to offset modal during drag
  func calculateDragOffset(_ translation: CGFloat) -> CGFloat {
    if translation < 0 {
      // Resist upward dragging with square root function
      return -sqrt(abs(translation)) * 4
    } else {
      // Allow downward dragging with resistance
      return translation * 0.7
    }
  }

  /// Handles the end of drag gesture
  func handleDragEnd(_ value: DragGesture.Value) {
    let velocity = value.predictedEndLocation.y - value.location.y
    let shouldDismiss =
      value.translation.height > behavior.dismissDistanceThreshold ||
      velocity > behavior.dismissVelocityThreshold

    if shouldDismiss {
      dismissModal()
    } else {
      // Return to original position
      withAnimation(dragAnimation) {
        dragOffset = 0
      }
    }
  }

  /// Dismisses the modal with animation
  func dismissModal() {
    // Dismiss keyboard if it's visible
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    
    // Use standardSpring for consistent animations
    withAnimation(.spring(
      response: standardSpring.response,
      dampingFraction: standardSpring.dampingFraction
    )) {
      isPresented = false
      keyboardHeight = 0
    }
  }

  /// Transition animation for modal appearance/disappearance
  var modalTransition: AnyTransition {
    // Use standardSpring for consistent animations
    let springAnimation = Animation.spring(
      response: standardSpring.response,
      dampingFraction: standardSpring.dampingFraction
    )

    return .asymmetric(
      insertion: .move(edge: .bottom)
        .combined(with: .opacity)
        .animation(springAnimation),
      removal: .move(edge: .bottom)
        .combined(with: .opacity)
        .animation(springAnimation)
    )
  }
}
