//
//  ModalConfiguration.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI

/// Configuration options for the Modal's visual appearance.
public struct ModalAppearance: Equatable, Sendable {
  /// The background color of the modal
  public var background: Color

  /// The background color of the overlay behind the modal
  public var overlayColor: Color

  /// Corner radius of the modal
  public var cornerRadius: CGFloat

  /// Horizontal padding around the modal content
  public var horizontalPadding: CGFloat

  /// Bottom padding for the modal
  public var bottomPadding: CGFloat

  /// Whether to show the drag indicator at the top of the modal
  public var showDragIndicator: Bool

  /// Color of the drag indicator (if shown)
  public var dragIndicatorColor: Color

  /// Maximum height (as percentage of screen height, 0.0-1.0)
  public var maxHeightRatio: CGFloat

  /// Animation used for size changes
  public var sizeChangeAnimation: Animation

  /// Threshold for allowing content to shrink (in points)
  /// A higher value means the modal will only shrink when content is reduced significantly
  public var contentShrinkThreshold: CGFloat

  /// Threshold for detecting content growth in scroll views (in points)
  /// A lower value means the modal will be more responsive to small content changes
  public var contentGrowthThreshold: CGFloat

  /// Creates a custom appearance configuration
  /// - Parameters:
  ///   - background: Background color of the modal
  ///   - overlayColor: Color of the dimmed background overlay
  ///   - cornerRadius: Corner radius of the modal
  ///   - horizontalPadding: Horizontal padding around the modal
  ///   - bottomPadding: Bottom padding for the modal
  ///   - showDragIndicator: Whether to show the drag indicator
  ///   - dragIndicatorColor: Color of the drag indicator
  ///   - maxHeightRatio: Maximum height as percentage of screen (0.0-1.0)
  ///   - sizeChangeAnimation: Animation used for size changes
  ///   - contentShrinkThreshold: Threshold for allowing content to shrink (in points)
  ///   - contentGrowthThreshold: Threshold for detecting content growth in scroll views (in points)
  public init(
    background: Color = Color(.systemBackground),
    overlayColor: Color = Color.black.opacity(0.4),
    cornerRadius: CGFloat = 38,
    horizontalPadding: CGFloat = 20,
    bottomPadding: CGFloat = 0,
    showDragIndicator: Bool = true,
    dragIndicatorColor: Color = Color(.systemGray3),
    maxHeightRatio: CGFloat = 0.85,
    sizeChangeAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.7),
    contentShrinkThreshold: CGFloat = 80,
    contentGrowthThreshold: CGFloat = 20
  ) {
    self.background = background
    self.overlayColor = overlayColor
    self.cornerRadius = cornerRadius
    self.horizontalPadding = horizontalPadding
    self.bottomPadding = bottomPadding
    self.showDragIndicator = showDragIndicator
    self.dragIndicatorColor = dragIndicatorColor
    self.maxHeightRatio = min(max(maxHeightRatio, 0), 1)
    self.sizeChangeAnimation = sizeChangeAnimation
    self.contentShrinkThreshold = contentShrinkThreshold
    self.contentGrowthThreshold = contentGrowthThreshold
  }

  /// Default appearance settings - adapts to system light/dark mode
  public static let `default` = ModalAppearance()

  /// Minimal appearance with no drag indicator - adapts to system light/dark mode
  public static let minimal = ModalAppearance(
    cornerRadius: 24,
    showDragIndicator: false
  )
  
  /// Card-style appearance with more rounded corners
  public static let card = ModalAppearance(
    cornerRadius: 20,
    horizontalPadding: 16,
    bottomPadding: 16
  )

  /// Sheet-style appearance that matches native iOS sheet presentation.
  /// Edge-to-edge with system-matching corner radius and no side padding.
  public static let sheet = ModalAppearance(
    cornerRadius: 20,
    horizontalPadding: 0
  )
}

/// Configuration options for the Modal's interaction behavior.
public struct ModalBehavior: Equatable, Sendable {
  /// Whether the modal can be dismissed by dragging down
  public var enableDragToDismiss: Bool

  /// Whether tapping the overlay dismisses the modal
  public var tapToDismiss: Bool

  /// Velocity threshold for dismissal (pixels/second)
  public var dismissVelocityThreshold: CGFloat

  /// Distance threshold for dismissal (pixels)
  public var dismissDistanceThreshold: CGFloat

  /// Creates a custom behavior configuration
  /// - Parameters:
  ///   - enableDragToDismiss: Whether dragging can dismiss the modal
  ///   - tapToDismiss: Whether tapping the overlay dismisses the modal
  ///   - dismissVelocityThreshold: Velocity threshold for dismissal
  ///   - dismissDistanceThreshold: Distance threshold for dismissal
  public init(
    enableDragToDismiss: Bool = true,
    tapToDismiss: Bool = true,
    dismissVelocityThreshold: CGFloat = 170,
    dismissDistanceThreshold: CGFloat = 100
  ) {
    self.enableDragToDismiss = enableDragToDismiss
    self.tapToDismiss = tapToDismiss
    self.dismissVelocityThreshold = dismissVelocityThreshold
    self.dismissDistanceThreshold = dismissDistanceThreshold
  }

  /// Default behavior settings
  public static let `default` = ModalBehavior()

  /// Non-dismissible modal that can only be dismissed programmatically
  public static let nonDismissible = ModalBehavior(
    enableDragToDismiss: false,
    tapToDismiss: false
  )

  /// Easy-to-dismiss modal with lower thresholds
  public static let easyDismiss = ModalBehavior(
    dismissVelocityThreshold: 100,
    dismissDistanceThreshold: 50
  )
}
