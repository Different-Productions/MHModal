//
//  View+PresentModal.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

// MARK: - Core API

extension View {

  /// Presents a self-sizing sheet modal.
  ///
  /// The sheet automatically sizes to its content using a custom self-sizing
  /// detent backed by `UISheetPresentationController`.
  ///
  /// - Parameters:
  ///   - isPresented: Binding that controls modal presentation.
  ///   - content: The content to display inside the sheet.
  public func presentModal<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: .default,
      behavior: .default,
      content: content
    )
  }

  /// Presents a self-sizing sheet modal with custom appearance.
  public func presentModal<Content: View>(
    isPresented: Binding<Bool>,
    appearance: ModalAppearance,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: appearance,
      behavior: .default,
      content: content
    )
  }

  /// Presents a self-sizing sheet modal with custom behavior.
  public func presentModal<Content: View>(
    isPresented: Binding<Bool>,
    behavior: ModalBehavior,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: .default,
      behavior: behavior,
      content: content
    )
  }

  /// Presents a self-sizing sheet modal with full customization.
  public func presentModal<Content: View>(
    isPresented: Binding<Bool>,
    appearance: ModalAppearance,
    behavior: ModalBehavior,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self.modifier(
      PresentModalModifier(
        isPresented: isPresented,
        appearance: appearance,
        behavior: behavior,
        content: content
      )
    )
  }
}

// MARK: - Phase-Based API

extension View {

  /// Presents a self-sizing sheet modal with automatic content transitions between phases.
  ///
  /// When the `phase` value changes, the old content transitions out and new content
  /// transitions in while the sheet height morphs smoothly.
  ///
  /// - Parameters:
  ///   - isPresented: Binding that controls modal presentation.
  ///   - phase: The current phase value. Changing this triggers a content transition.
  ///   - appearance: Visual appearance configuration.
  ///   - behavior: Interaction behavior configuration.
  ///   - transition: The transition applied when the phase changes.
  ///   - content: A view builder that produces content for the given phase.
  public func presentModal<Phase: Hashable, ModalContent: View>(
    isPresented: Binding<Bool>,
    phase: Phase,
    appearance: ModalAppearance = .default,
    behavior: ModalBehavior = .default,
    transition: AnyTransition = .modalCrossFade,
    @ViewBuilder content: @escaping (Phase) -> ModalContent
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: appearance,
      behavior: behavior
    ) {
      ModalContentTransition(
        phase: phase,
        transition: transition,
        content: content
      )
    }
  }
}

// MARK: - Convenience Modifiers

extension View {

  /// Presents a modal with minimal appearance (no grabber, 24pt corners).
  public func presentMinimalModal<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: .minimal,
      content: content
    )
  }

  /// Presents a modal with sheet appearance (matches system defaults).
  public func presentSheetModal<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    presentModal(
      isPresented: isPresented,
      appearance: .sheet,
      content: content
    )
  }
}

// MARK: - Presentation Modifier

private struct PresentModalModifier<ModalContent: View>: ViewModifier {

  @Binding var isPresented: Bool
  let appearance: ModalAppearance
  let behavior: ModalBehavior
  let content: () -> ModalContent

  func body(content: Content) -> some View {
    content
      .background(
        MHModalPresenter(
          isPresented: $isPresented,
          appearance: appearance,
          behavior: behavior,
          content: self.content
        )
      )
  }
}
