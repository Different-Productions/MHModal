//
//  MHModalPresenter.swift
//  MHModal
//
//  UIViewControllerRepresentable that drives native sheet presentation
//  with self-sizing detents from a background representable.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

// MARK: - Self-Sizing Hosting Controller

/// A hosting controller that watches its own layout and invalidates the
/// sheet's detents whenever the SwiftUI content changes height.
/// This is what makes internal state changes (expanding sections, adding
/// list items, navigating between views) morph the sheet automatically.
final class SelfSizingHostingController<Content: View>: UIHostingController<Content> {

  private var lastKnownHeight: CGFloat = 0

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard presentingViewController != nil else { return }
    let newHeight = view.intrinsicContentSize.height
    guard newHeight != lastKnownHeight, newHeight > 0 else { return }
    lastKnownHeight = newHeight
    if let sheet = sheetPresentationController {
      sheet.animateChanges {
        sheet.invalidateDetents()
      }
    }
  }
}

// MARK: - Presenter

/// An invisible representable placed as a `.background()` that owns the
/// full UIKit presentation lifecycle: create → configure → present → dismiss.
struct MHModalPresenter<ModalContent: View>: UIViewControllerRepresentable {

  @Binding var isPresented: Bool
  let appearance: ModalAppearance
  let behavior: ModalBehavior
  let content: () -> ModalContent

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIViewController {
    let host = UIViewController()
    host.view.backgroundColor = .clear
    return host
  }

  func updateUIViewController(_ host: UIViewController, context: Context) {
    let coordinator = context.coordinator
    coordinator.binding = $isPresented

    if isPresented {
      if let hosting = coordinator.presentedHosting {
        // Already presented — update content (phase changes, etc.)
        // Height morphing is handled by SelfSizingHostingController.
        hosting.rootView = content()
        hosting.view.backgroundColor = UIColor(appearance.background)
        hosting.isModalInPresentation = !behavior.isDismissible

        if let sheet = hosting.sheetPresentationController {
          sheet.prefersGrabberVisible = appearance.showGrabber
          if let cornerRadius = appearance.cornerRadius {
            sheet.preferredCornerRadius = cornerRadius
          }
        }
      } else {
        // First presentation
        let hosting = SelfSizingHostingController(rootView: content())
        hosting.sizingOptions = .intrinsicContentSize
        hosting.view.backgroundColor = UIColor(appearance.background)
        hosting.isModalInPresentation = !behavior.isDismissible
        coordinator.presentedHosting = hosting

        if let sheet = hosting.sheetPresentationController {
          configureSheet(sheet, hosting: hosting)
          sheet.delegate = coordinator
        }

        DispatchQueue.main.async {
          guard coordinator.presentedHosting === hosting else { return }
          guard host.presentedViewController == nil else { return }
          host.present(hosting, animated: true)
        }
      }
    } else {
      if let hosting = coordinator.presentedHosting {
        coordinator.presentedHosting = nil
        if hosting.presentingViewController != nil {
          host.dismiss(animated: true)
        }
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(binding: $isPresented)
  }

  // MARK: - Sheet Configuration

  private func configureSheet(
    _ sheet: UISheetPresentationController,
    hosting: SelfSizingHostingController<ModalContent>
  ) {
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

  // MARK: - Coordinator

  final class Coordinator: NSObject, UISheetPresentationControllerDelegate {
    var binding: Binding<Bool>
    var presentedHosting: SelfSizingHostingController<ModalContent>?

    init(binding: Binding<Bool>) {
      self.binding = binding
    }

    func presentationControllerDidDismiss(
      _ presentationController: UIPresentationController
    ) {
      binding.wrappedValue = false
      presentedHosting = nil
    }
  }
}
#endif
