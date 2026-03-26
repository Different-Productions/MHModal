#if os(iOS)
import SwiftUI
import UIKit

struct MHModalPresenter<ModalContent: View>: UIViewControllerRepresentable {

  @Binding var isPresented: Bool
  let appearance: ModalAppearance
  let behavior: ModalBehavior
  let transitionID: AnyHashable?
  let content: () -> ModalContent

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIViewController(context: Context) -> UIViewController {
    UIViewController()
  }

  func updateUIViewController(_ host: UIViewController, context: Context) {
    let coordinator = context.coordinator
    coordinator.parent = self

    if isPresented {
      if coordinator.sheetController == nil {
        coordinator.present(from: host)
      } else if let nav = coordinator.sheetController {
        // Already presented — check for phase transition
        let needsTransition = transitionID != nil
          && transitionID != coordinator.lastTransitionID

        if needsTransition {
          let hosting = coordinator.makeHosting()
          hosting.navigationItem.hidesBackButton = true
          nav.pushViewController(hosting, animated: true)
          coordinator.lastTransitionID = transitionID
        } else if let hosting = nav.topViewController as? ModalHostingController {
          hosting.rootView = AnyView(
            coordinator.parent.content()
              .environment(\.modalNavigator, coordinator.navigator)
          )
        }
      }
    } else {
      if coordinator.sheetController != nil {
        host.dismiss(animated: true)
        coordinator.sheetController = nil
      }
    }
  }

  @MainActor
  final class Coordinator {
    var parent: MHModalPresenter
    var sheetController: ModalViewController?
    var lastTransitionID: AnyHashable?
    let navigator = ModalNavigator()

    init(parent: MHModalPresenter) {
      self.parent = parent
    }

    func present(from host: UIViewController) {
      let rootHosting = makeHosting()
      let vc = ModalViewController(rootViewController: rootHosting)
      vc.view.backgroundColor = UIColor(parent.appearance.background)
      vc.modalPresentationStyle = .pageSheet
      vc.isModalInPresentation = !parent.behavior.isDismissible
      vc.configureSheet()
      navigator.modalVC = vc
      lastTransitionID = parent.transitionID

      vc.onDismissed = { [weak self] in
        self?.sheetController = nil
        DispatchQueue.main.async {
          self?.parent.isPresented = false
        }
      }

      sheetController = vc
      host.present(vc, animated: true)
    }

    func makeHosting() -> ModalHostingController {
      let hosting = ModalHostingController(rootView: AnyView(
        parent.content()
          .environment(\.modalNavigator, navigator)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      ))
      hosting.view.backgroundColor = UIColor(parent.appearance.background)
      return hosting
    }
  }
}
#endif
