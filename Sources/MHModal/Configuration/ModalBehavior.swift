//
//  ModalBehavior.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI

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
