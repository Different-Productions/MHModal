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
  /// Uses `sheetPresentationController` with a self-sizing detent.
  /// The system handles corner radius, dimming, and keyboard avoidance.
  ///
  /// ```swift
  /// presentMHModal {
  ///     Text("Hello from MHModal")
  ///         .padding()
  /// }
  /// ```
  @MainActor
  public func presentMHModal<Content: View>(
    appearance: ModalAppearance = .default,
    behavior: ModalBehavior = .default,
    @ViewBuilder content: @escaping () -> Content
  ) {
    let hosting = SelfSizingHostingController(rootView: content())
    hosting.sizingOptions = .intrinsicContentSize
    hosting.view.backgroundColor = UIColor(appearance.background)
    hosting.isModalInPresentation = !behavior.isDismissible

    if let sheet = hosting.sheetPresentationController {
      let selfSizing = UISheetPresentationController.Detent.custom(
        identifier: .init("selfSizing")
      ) { [weak hosting] _ in
        hosting?.view.intrinsicContentSize.height
      }

      if let ratio = appearance.maxHeightRatio {
        let percentage = UISheetPresentationController.Detent.custom(
          identifier: .init("maxHeight")
        ) { context in
          context.maximumDetentValue * ratio
        }
        sheet.detents = [selfSizing, percentage]
      } else {
        sheet.detents = [selfSizing]
      }

      sheet.prefersGrabberVisible = appearance.showGrabber

      if let cornerRadius = appearance.cornerRadius {
        sheet.preferredCornerRadius = cornerRadius
      }

      if !appearance.dimBackground {
        sheet.largestUndimmedDetentIdentifier = .init("selfSizing")
      }
    }

    present(hosting, animated: true)
  }
}
#endif
