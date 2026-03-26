#if os(iOS)
import SwiftUI
import UIKit

extension UIViewController {

  @MainActor
  public func presentMHModal<Content: View>(
    appearance: ModalAppearance = .default,
    behavior: ModalBehavior = .default,
    @ViewBuilder content: @escaping () -> Content
  ) {
    let navigator = ModalNavigator()
    let hosting = ModalHostingController(rootView: AnyView(
      content().environment(\.modalNavigator, navigator)
    ))
    hosting.view.backgroundColor = UIColor(appearance.background)

    let vc = ModalViewController(rootViewController: hosting)
    vc.view.backgroundColor = UIColor(appearance.background)
    vc.modalPresentationStyle = .pageSheet
    vc.isModalInPresentation = !behavior.isDismissible
    vc.configureSheet()
    navigator.modalVC = vc

    present(vc, animated: true)
  }
}
#endif
