#if os(iOS)
import SwiftUI
import UIKit

final class ModalHostingController: UIHostingController<AnyView> {
  override func viewDidLoad() {
    super.viewDidLoad()
    safeAreaRegions = []
    sizingOptions = .intrinsicContentSize
  }
}
#endif
