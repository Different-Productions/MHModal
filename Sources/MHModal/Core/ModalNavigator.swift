#if os(iOS)
import SwiftUI
import UIKit

/// Push/pop navigation within a presented modal.
///
/// ```swift
/// @Environment(\.modalNavigator) var navigator
///
/// Button("Detail") {
///     navigator?.push(title: "Detail") {
///         DetailView()
///     }
/// }
/// ```
@MainActor
@Observable
public final class ModalNavigator {

  weak var modalVC: ModalViewController?

  public func push<Content: View>(
    title: String? = nil,
    @ViewBuilder content: () -> Content
  ) {
    guard let nav = modalVC else { return }
    let hosting = ModalHostingController(rootView: AnyView(content()))
    hosting.view.backgroundColor = nav.view.backgroundColor
    if let title {
      hosting.navigationItem.title = title
    }
    nav.pushViewController(hosting, animated: true)
  }

  public func pop() {
    modalVC?.popViewController(animated: true)
  }
}

// MARK: - Environment Key

private struct ModalNavigatorKey: EnvironmentKey {
  static let defaultValue: ModalNavigator? = nil
}

extension EnvironmentValues {
  public var modalNavigator: ModalNavigator? {
    get { self[ModalNavigatorKey.self] }
    set { self[ModalNavigatorKey.self] = newValue }
  }
}
#endif
