//
//  UIViewController+MHModal.swift
//  MHModal
//
//  UIKit bridge for presenting MHModal content from any UIViewController.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

  /// Presents SwiftUI content as a sheet from any UIViewController.
  ///
  /// Just provide the content — MHModal handles sizing, corner radius,
  /// dimming, and presentation automatically.
  ///
  /// ```swift
  /// presentMHModal {
  ///     Text("Hello from MHModal")
  ///         .padding()
  /// }
  /// ```
  @MainActor
  public func presentMHModal<Content: View>(
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
