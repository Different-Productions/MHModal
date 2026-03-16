//
//  ModalConfiguration.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI

/// Configuration for the modal's visual appearance.
///
/// Native sheet properties are configured through `UISheetPresentationController`.
/// All presentations are edge-to-edge; corner radius, grabber visibility,
/// and dimming are forwarded directly to the sheet.
public struct ModalAppearance: Equatable, Sendable {
  /// The background color of the modal content.
  public var background: Color

  /// Whether to show the grabber at the top of the sheet.
  public var showGrabber: Bool

  /// Corner radius of the sheet. `nil` uses the system default.
  public var cornerRadius: CGFloat?

  /// Maximum height as a ratio of screen height (0.0–1.0).
  /// `nil` means pure self-sizing (no percentage-based detent).
  /// When set, adds a percentage detent alongside the self-sizing detent.
  public var maxHeightRatio: CGFloat?

  /// Whether the area behind the sheet is dimmed.
  /// When `false`, sets `largestUndimmedDetentIdentifier` so the
  /// user can interact with content behind the sheet.
  public var dimBackground: Bool

  /// Creates a custom appearance configuration.
  /// - Parameters:
  ///   - background: Background color of the modal content.
  ///   - showGrabber: Whether to show the sheet grabber.
  ///   - cornerRadius: Corner radius (`nil` = system default).
  ///   - maxHeightRatio: Maximum height ratio (`nil` = pure self-sizing).
  ///   - dimBackground: Whether to dim the background.
  public init(
    background: Color = Color(.systemBackground),
    showGrabber: Bool = true,
    cornerRadius: CGFloat? = nil,
    maxHeightRatio: CGFloat? = nil,
    dimBackground: Bool = true
  ) {
    self.background = background
    self.showGrabber = showGrabber
    self.cornerRadius = cornerRadius
    if let ratio = maxHeightRatio {
      self.maxHeightRatio = min(max(ratio, 0), 1)
    } else {
      self.maxHeightRatio = nil
    }
    self.dimBackground = dimBackground
  }

  /// Default appearance — system background, grabber visible, self-sizing.
  public static let `default` = ModalAppearance()

  /// Minimal appearance — no grabber, 24pt corner radius.
  public static let minimal = ModalAppearance(
    showGrabber: false,
    cornerRadius: 24
  )

  /// Sheet appearance — identical to default (native sheets are edge-to-edge).
  public static let sheet = ModalAppearance()
}

/// Configuration for the modal's interaction behavior.
public struct ModalBehavior: Equatable, Sendable {
  /// Whether the user can dismiss the modal interactively (drag or tap outside).
  /// When `false`, maps to `isModalInPresentation = true` on the sheet.
  public var isDismissible: Bool

  /// Creates a custom behavior configuration.
  /// - Parameter isDismissible: Whether the modal can be dismissed interactively.
  public init(isDismissible: Bool = true) {
    self.isDismissible = isDismissible
  }

  /// Default behavior — dismissible by drag or tap.
  public static let `default` = ModalBehavior()

  /// Non-dismissible — can only be dismissed programmatically.
  public static let nonDismissible = ModalBehavior(isDismissible: false)
}
