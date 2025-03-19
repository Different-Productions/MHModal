//
//  ModalView.swift
//  MHModal
//
//  Created by Michael Harrigan on 11/1/24.
//

import SwiftUI
import UIKit

/// A modern, dynamically-sized modal view for SwiftUI that automatically adjusts to its content.
///
/// `ModalView` provides a streamlined, beautiful modal presentation with these key features:
/// - Automatic content-driven sizing with smooth animations
/// - Interactive drag-to-dismiss gesture
/// - Customizable appearance
/// - Spring-based animations for natural motion
/// - Support for scrolling when content exceeds available space
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @State private var showModal = false
///
///     var body: some View {
///         Button("Show Modal") {
///             showModal = true
///         }
///         .modal(isPresented: $showModal) {
///             Text("This content will automatically size the modal")
///                 .padding()
///         }
///     }
/// }
/// ```
public struct ModalView<Content: View>: View {
  // MARK: - Properties
  @Binding var isPresented: Bool
  let content: Content
  let appearance: ModalAppearance
  let behavior: ModalBehavior

  // State for internal modal functionality
  @State var contentSize: CGSize = .zero
  @State var dragOffset: CGFloat = 0
  @GestureState var isDragging = false

  // MARK: - Initialization

  /// Creates a new `ModalView` with the specified content and configuration.
  ///
  /// - Parameters:
  ///   - isPresented: Controls whether the modal is displayed
  ///   - appearance: Visual appearance settings (optional)
  ///   - behavior: Interaction behavior settings (optional)
  ///   - content: The content to display inside the modal
  public init(
    isPresented: Binding<Bool>,
    appearance: ModalAppearance = .default,
    behavior: ModalBehavior = .default,
    @ViewBuilder content: () -> Content
  ) {
    self._isPresented = isPresented
    self.appearance = appearance
    self.behavior = behavior
    self.content = content()
  }

  // MARK: - Animation Configuration

  /// Spring animation parameters for dragging
  let dragSpring = (response: 0.35, dampingFraction: 0.7)

  /// Spring animation parameters for standard animations
  let standardSpring = (response: 0.45, dampingFraction: 0.8)

  // MARK: - Properties

  /// Calculate modal height based on content size and max height ratio
  var modalHeight: CGFloat {
    let maxHeight = screenHeight * appearance.maxHeightRatio

    // Add a small buffer (20pt) to ensure the content fits comfortably
    let totalContentHeight = contentSize.height + topPadding

    // Simply use the content height - this will always adjust to actual content
    // with a small buffer to ensure it fits comfortably
    let desiredHeight = totalContentHeight

    // Use a minimum height of 50pt to prevent collapsing to tiny sizes
    return min(max(desiredHeight, 50), maxHeight)
  }

  /// Top padding for the modal content
  var topPadding: CGFloat {
    appearance.showDragIndicator ? 36 : 0
  }

  /// Animation for drag gestures
  var dragAnimation: Animation {
    isDragging ?
      .interactiveSpring() :
      .spring(response: dragSpring.response, dampingFraction: dragSpring.dampingFraction)
  }

  /// The threshold for significant content shrinking
  var shrinkThreshold: CGFloat {
    appearance.contentShrinkThreshold
  }

  /// The threshold for content growth detection
  var growthThreshold: CGFloat {
    appearance.contentGrowthThreshold
  }
  
  /// Animate modal resize when content height changes
  func animateModalResize() {
    // Use the specific animation for content size changes
    withAnimation(appearance.sizeChangeAnimation) {
      // This is used to trigger the animation when resizing
      // It relies on the .animation(appearance.sizeChangeAnimation, value: modalHeight)
      // modifier on the view
      _ = modalHeight
    }
  }

  // MARK: - Body

  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        if isPresented {
          // Semi-transparent overlay
          overlayView

          // Modal content
          modalContentView
        }
      }
      .onAppear {
        // Store the screen height for calculations
        screenHeight = geometry.size.height
      }
    }
  }

  /// Store screen height from GeometryReader
  @State var screenHeight: CGFloat = 340
  
  /// Keyboard height for adjusting modal position
  @State var keyboardHeight: CGFloat = 0
  
  /// Setup keyboard observers
  func setupKeyboardObservers() {
    // Remove any existing observers to avoid duplicates
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    
    // Add keyboard show observer
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: .main
    ) { notification in
      if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
          keyboardHeight = keyboardFrame.height
        }
      }
    }
    
    // Add keyboard hide observer
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: .main
    ) { _ in
      withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
        keyboardHeight = 0
      }
    }
  }
  
}
