//
//  ModalAppearance.swift
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
  public init(
    background: Color = Color(.systemBackground),
    overlayColor: Color = Color.black.opacity(0.4),
    cornerRadius: CGFloat = 38,
    horizontalPadding: CGFloat = 8,
    bottomPadding: CGFloat = 0,
    showDragIndicator: Bool = true,
    dragIndicatorColor: Color = Color(.systemGray3),
    maxHeightRatio: CGFloat = 0.85
  ) {
    self.background = background
    self.overlayColor = overlayColor
    self.cornerRadius = cornerRadius
    self.horizontalPadding = horizontalPadding
    self.bottomPadding = bottomPadding
    self.showDragIndicator = showDragIndicator
    self.dragIndicatorColor = dragIndicatorColor
    self.maxHeightRatio = min(max(maxHeightRatio, 0), 1)
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
