//
//  UIViewController+MHModal.swift
//  MHModal
//
//  UIKit bridge for presenting MHModal content from any UIViewController.
//  Equivalent to BoosterKit's BoosterViewController — handles hosting controller
//  lifecycle, presentation, and dismiss wiring automatically.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

  /// Presents SwiftUI content inside an MHModal from any UIViewController.
  ///
  /// The content closure receives an `isPresented` binding for programmatic
  /// dismissal. Drag-to-dismiss and tap-overlay-to-dismiss work automatically.
  ///
  /// ```swift
  /// presentMHModal { isPresented in
  ///     MyModalContent(isPresented: isPresented)
  /// }
  /// ```
  ///
  /// For content that only needs gesture-based dismiss, ignore the binding:
  /// ```swift
  /// presentMHModal { _ in
  ///     Text("Hello from MHModal")
  /// }
  /// ```
  @MainActor
  public func presentMHModal<Content: View>(
    appearance: ModalAppearance = .sheet,
    behavior: ModalBehavior = .default,
    @ViewBuilder content: @escaping (_ isPresented: Binding<Bool>) -> Content
  ) {
    let hostingController = UIHostingController(
      rootView: MHModalHostView(
        appearance: appearance,
        behavior: behavior,
        content: content
      )
    )
    hostingController.view.backgroundColor = .clear
    hostingController.modalPresentationStyle = .overFullScreen
    hostingController.modalTransitionStyle = .crossDissolve

    present(hostingController, animated: false)
  }
}

/// Internal SwiftUI view that hosts the MHModal presentation.
/// Manages the isPresented state and dismisses the hosting controller when closed.
private struct MHModalHostView<Content: View>: View {

  let appearance: ModalAppearance
  let behavior: ModalBehavior
  @ViewBuilder let content: (_ isPresented: Binding<Bool>) -> Content

  @State private var isPresented = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Color.clear
      .presentModal(
        isPresented: $isPresented,
        appearance: appearance,
        behavior: behavior
      ) {
        content($isPresented)
      }
      .onAppear {
        isPresented = true
      }
      .onChange(of: isPresented) { _, newValue in
        if !newValue {
          dismiss()
        }
      }
  }
}
#endif
