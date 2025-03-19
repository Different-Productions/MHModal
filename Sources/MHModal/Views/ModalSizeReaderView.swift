//
//  ModalSizeReaderView.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI

/// Size reader and animation handling for the modal.
extension ModalView {
  /// Size reader that monitors content size changes
  @ViewBuilder
  var sizeReaderView: some View {
    GeometryReader { proxy in
      Color.clear
        .preference(key: SizePreferenceKey.self, value: proxy.size)
    }
    .onPreferenceChange(SizePreferenceKey.self) { [contentSize] size in
      // Skip empty updates or when there's no change
      guard size != .zero && size != contentSize else { return }

      // Always update size when it changes
      // This is simpler and more reliable for adjusting to content
      Task { @MainActor in
        // Update size and trigger animation (on main thread)
        self.contentSize = size
        self.animateModalResize()
      }
    }
  }
}
