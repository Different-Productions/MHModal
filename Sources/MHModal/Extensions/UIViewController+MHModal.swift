//
//  UIViewController+MHModal.swift
//  MHModal
//
//  UIKit bridge — presents SwiftUI content as a native iOS sheet
//  with self-sizing detents.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

  /// Presents SwiftUI content as a native self-sizing sheet.
  ///
  /// Uses `sheetPresentationController` with a self-sizing detent and `.large()`.
  /// System handles corner radius, dimming, and presentation.
  ///
  /// ```swift
  /// presentMorphingModal {
  ///     Text("Hello from MHModal")
  ///         .padding()
  /// }
  /// ```
  @MainActor
  public func presentMorphingModal<Content: View>(
    @ViewBuilder content: @escaping () -> Content
  ) {
    let hostingController = UIHostingController(rootView: content())
    hostingController.view.backgroundColor = .systemBackground
    hostingController.sizingOptions = .intrinsicContentSize

    if let sheet = hostingController.sheetPresentationController {
      let selfSizingDetent = UISheetPresentationController.Detent.custom { [weak hostingController] _ in
        hostingController?.view.intrinsicContentSize.height
      }
      sheet.detents = [selfSizingDetent, .large()]
      sheet.prefersGrabberVisible = true
    }

    present(hostingController, animated: true)
  }
}
#endif
