//
//  ModalCoordinator.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// A lightweight coordinator for programmatic modal control.
///
/// Use `ModalCoordinator` when you need imperative `present()` / `dismiss()`
/// calls instead of (or alongside) a `Binding<Bool>`. Bind its `isPresented`
/// property to the `.presentModal` modifier:
///
/// ```swift
/// @State private var coordinator = ModalCoordinator()
///
/// var body: some View {
///     Button("Show") { coordinator.present() }
///         .presentModal(isPresented: $coordinator.isPresented) {
///             Text("Hello")
///         }
/// }
/// ```
@MainActor
@Observable
public final class ModalCoordinator {

  /// Whether the modal is currently presented.
  public var isPresented: Bool = false

  /// Visual appearance configuration.
  public let appearance: ModalAppearance

  /// Interaction behavior configuration.
  public let behavior: ModalBehavior

  /// Creates a new coordinator with the specified configuration.
  /// - Parameters:
  ///   - appearance: Visual appearance settings.
  ///   - behavior: Interaction behavior settings.
  public init(
    appearance: ModalAppearance = .default,
    behavior: ModalBehavior = .default
  ) {
    self.appearance = appearance
    self.behavior = behavior
  }

  /// Presents the modal.
  public func present() {
    isPresented = true
  }

  /// Dismisses the modal.
  public func dismiss() {
    isPresented = false
  }
}
