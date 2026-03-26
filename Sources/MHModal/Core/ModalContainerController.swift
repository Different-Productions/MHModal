#if os(iOS)
import UIKit

/// A navigation controller that presents content in a self-sizing sheet.
///
/// Uses `UISheetPresentationController.Detent.custom` to measure the current
/// top view controller's content height. Push/pop transitions use a custom
/// cross-dissolve animator that syncs `animateChanges { invalidateDetents() }`
/// with the content fade, producing a smooth sheet height morph.
@MainActor
final class ModalViewController: UINavigationController {

  var onDismissed: (() -> Void)?

  // MARK: - Initialization

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    navigationBar.prefersLargeTitles = false
    isNavigationBarHidden = true
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isBeingDismissed {
      onDismissed?()
    }
  }

  // MARK: - Sheet Configuration

  func configureSheet() {
    guard let sheet = sheetPresentationController else { return }

    let selfSizingDetent = UISheetPresentationController.Detent.custom { [weak self] _ in
      guard let self, let currentVC = self.topViewController else { return nil }
      let width = self.view.bounds.width

      // UIHostingController doesn't work with systemLayoutSizeFitting.
      // Use intrinsicContentSize — returns compact content height
      // regardless of the current frame.
      if currentVC is ModalHostingController {
        currentVC.view.frame.size.width = width
        currentVC.view.setNeedsLayout()
        currentVC.view.layoutIfNeeded()
        return currentVC.view.intrinsicContentSize.height
      }

      // Pure UIKit views — systemLayoutSizeFitting works perfectly.
      let targetSize = CGSize(
        width: width,
        height: UIView.layoutFittingCompressedSize.height
      )
      return currentVC.view.systemLayoutSizeFitting(
        targetSize,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel
      ).height
    }

    sheet.detents = [selfSizingDetent]
    sheet.prefersGrabberVisible = true
  }

}

// MARK: - UINavigationControllerDelegate

extension ModalViewController: UINavigationControllerDelegate {

  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    if !animated {
      sheetPresentationController?.invalidateDetents()
    }
  }

  func navigationController(
    _ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> (any UIViewControllerAnimatedTransitioning)? {
    ModalTransition(sheetController: sheetPresentationController)
  }
}

// MARK: - Cross-Dissolve Transition

/// Cross-dissolves between view controllers while morphing the sheet height.
private final class ModalTransition: NSObject, UIViewControllerAnimatedTransitioning {

  private weak var sheetController: UISheetPresentationController?

  init(sheetController: UISheetPresentationController?) {
    self.sheetController = sheetController
  }

  func transitionDuration(
    using transitionContext: (any UIViewControllerContextTransitioning)?
  ) -> TimeInterval {
    0.35
  }

  func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
    guard
      transitionContext.view(forKey: .from) != nil,
      let toView = transitionContext.view(forKey: .to),
      let toVC = transitionContext.viewController(forKey: .to)
    else {
      transitionContext.completeTransition(false)
      return
    }

    let container = transitionContext.containerView
    let duration = transitionDuration(using: transitionContext)

    toView.frame = transitionContext.finalFrame(for: toVC)
    toView.layoutIfNeeded()
    toView.alpha = 0
    container.addSubview(toView)

    // Hide old view immediately so it doesn't show through during the fade
    transitionContext.view(forKey: .from)?.alpha = 0

    UIView.animate(
      withDuration: duration,
      delay: 0,
      options: .curveEaseInOut
    ) {
      toView.alpha = 1
    } completion: { _ in
      let didComplete = !transitionContext.transitionWasCancelled
      transitionContext.completeTransition(didComplete)
    }

    // Morph the sheet height in sync with the cross-dissolve
    sheetController?.animateChanges {
      self.sheetController?.invalidateDetents()
    }
  }
}
#endif
