//
//  UIViewController+MHModal.swift
//  MHModal
//
//  UIKit bridge for presenting MHModal content from any UIViewController.
//  Uses sheetPresentationController with self-sizing detents — same approach
//  as BoosterKit. System handles corner radius, dimming, and presentation.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

  /// Presents SwiftUI content as a self-sizing sheet from any UIViewController.
  ///
  /// Uses `sheetPresentationController` with a self-sizing detent so the sheet
  /// height matches the content. System handles corner radius and dimming.
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

    if let sheet = hostingController.sheetPresentationController {
      let selfSizingDetent = UISheetPresentationController.Detent.custom { context in
        hostingController.view.systemLayoutSizeFitting(
          CGSize(
            width: context.maximumDetentValue,
            height: UIView.layoutFittingCompressedSize.height
          ),
          withHorizontalFittingPriority: .required,
          verticalFittingPriority: .fittingSizeLevel
        ).height
      }
      sheet.detents = [selfSizingDetent]
      sheet.prefersGrabberVisible = true
    }

    present(hostingController, animated: true)
  }
}
#endif
