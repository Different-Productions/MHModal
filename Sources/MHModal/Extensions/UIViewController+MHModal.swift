//
//  UIViewController+MHModal.swift
//  MHModal
//
//  UIKit bridge — presents SwiftUI content using MHModal's native
//  .presentModal() inside a transparent UIHostingController.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

  /// Presents SwiftUI content inside MHModal from any UIViewController.
  ///
  /// Uses MHModal's native `.presentModal()` for auto-sizing, scroll handling,
  /// and morphing. Just provide the content.
  ///
  /// ```swift
  /// presentMHModal {
  ///     Text("Hello from MHModal")
  ///         .padding()
  /// }
  /// ```
  @MainActor
  public func presentMHModal<Content: View>(
    appearance: ModalAppearance = .sheet,
    @ViewBuilder content: @escaping () -> Content
  ) {
    let host = MHModalHostView(appearance: appearance, content: content)
    let hostingController = UIHostingController(rootView: host)
    hostingController.view.backgroundColor = .clear
    hostingController.modalPresentationStyle = .overFullScreen
    hostingController.modalTransitionStyle = .crossDissolve

    present(hostingController, animated: false)
  }
}

private struct MHModalHostView<Content: View>: View {

  let appearance: ModalAppearance
  @ViewBuilder let content: () -> Content

  @State private var isPresented = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Color.clear
      .presentModal(isPresented: $isPresented, appearance: appearance) {
        content()
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
