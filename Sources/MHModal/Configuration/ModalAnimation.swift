//
//  ModalAnimation.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/15/26.
//

import SwiftUI

/// Animation configuration for the modal's transitions and interactions.
public struct ModalAnimation: Sendable {
  /// Animation used for morphing transitions when content size changes
  public var morph: Animation

  /// Animation used for drag gesture tracking
  public var drag: Animation

  /// Animation used for modal presentation
  public var present: Animation

  /// Animation used for modal dismissal
  public var dismiss: Animation

  /// Animation used for keyboard avoidance
  public var keyboard: Animation

  /// Creates a custom animation configuration
  /// - Parameters:
  ///   - morph: Animation for content size morphing transitions
  ///   - drag: Animation for drag gesture tracking
  ///   - present: Animation for modal presentation
  ///   - dismiss: Animation for modal dismissal
  ///   - keyboard: Animation for keyboard avoidance
  public init(
    morph: Animation = .spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.1),
    drag: Animation = .interactiveSpring(response: 0.25, dampingFraction: 0.86),
    present: Animation = .spring(response: 0.48, dampingFraction: 0.78),
    dismiss: Animation = .spring(response: 0.35, dampingFraction: 0.88),
    keyboard: Animation = .spring(response: 0.35, dampingFraction: 0.88)
  ) {
    self.morph = morph
    self.drag = drag
    self.present = present
    self.dismiss = dismiss
    self.keyboard = keyboard
  }

  /// Default spring animations optimized for natural modal interactions
  public static let `default` = ModalAnimation()

  /// Reduced motion animations using simple ease-in-out curves
  public static let reduced = ModalAnimation(
    morph: .easeInOut(duration: 0.2),
    drag: .easeInOut(duration: 0.2),
    present: .easeInOut(duration: 0.2),
    dismiss: .easeInOut(duration: 0.2),
    keyboard: .easeInOut(duration: 0.2)
  )
}
