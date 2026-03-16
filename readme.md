# MHModal

A morphing modal for iOS that automatically resizes to fit its content with smooth spring animations.

[![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26+-blue.svg)](https://developer.apple.com/ios/)
[![Tests](https://github.com/Different-Productions/MHModal/actions/workflows/swift.yml/badge.svg)](https://github.com/Different-Productions/MHModal/actions/workflows/swift.yml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## Features

- **Auto-morphing** — modal height animates to match content as it changes
- **Drag to dismiss** — natural gesture with scale, shadow, and corner radius feedback
- **Keyboard aware** — modal repositions and resizes when the keyboard appears
- **Phase-based transitions** — cross-fade between content phases for multi-step flows
- **Configurable** — appearance, behavior, and animation are all customizable

## Installation

Add MHModal as a Swift Package dependency:

```swift
.package(url: "https://github.com/Different-Productions/MHModal.git", branch: "master")
```

## Usage

### Basic

```swift
import MHModal

struct MyView: View {
    @State private var showModal = false

    var body: some View {
        Button("Show") { showModal = true }
            .presentModal(isPresented: $showModal) {
                Text("Hello from MHModal")
                    .padding()
            }
    }
}
```

### Custom Appearance

```swift
.presentModal(
    isPresented: $show,
    appearance: ModalAppearance(
        cornerRadius: 24,
        horizontalPadding: 16,
        maxHeightRatio: 0.7
    )
) {
    MyContent()
}
```

### Phase-Based Flows

```swift
.presentModal(isPresented: $show, phase: currentStep) { step in
    switch step {
    case 0: WelcomeView()
    case 1: DetailsView()
    default: DoneView()
    }
}
```

The modal cross-fades between phases and morphs to the new content height.

### Convenience Styles

```swift
// Sheet-style (edge-to-edge, matches native iOS sheets)
.presentSheetModal(isPresented: $show) { ... }

// No drag indicator
.presentMinimalModal(isPresented: $show) { ... }

// Card-style with tighter spacing
.presentCardModal(isPresented: $show) { ... }
```

### UIKit

Present from any `UIViewController` — handles hosting controller lifecycle and dismiss wiring automatically.

```swift
viewController.presentMorphingModal { isPresented in
    MyModalContent(isPresented: isPresented)
}
```

Defaults to `.sheet` appearance (edge-to-edge). Pass a custom appearance if needed:

```swift
viewController.presentMorphingModal(appearance: .default) { _ in
    Text("Floating card style")
}
```

### Lists and Scrollable Content

Use `VStack` + `ForEach` instead of `List` inside the modal. The SDK provides its own scroll handling — nesting a `List` (which is itself a scroll view) causes conflicts.

```swift
.presentModal(isPresented: $show) {
    VStack(spacing: 12) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

## Configuration

### ModalAppearance

| Property | Default | Description |
|----------|---------|-------------|
| `background` | `.systemBackground` | Modal background color |
| `overlayColor` | `.black.opacity(0.4)` | Dimmed overlay behind modal |
| `cornerRadius` | `38` | Corner radius |
| `horizontalPadding` | `20` | Side padding |
| `bottomPadding` | `0` | Bottom padding |
| `showsDragIndicator` | `true` | Show the grab handle |
| `maxHeightRatio` | `0.85` | Max height as fraction of screen |

### ModalBehavior

| Property | Default | Description |
|----------|---------|-------------|
| `isDragToDismissEnabled` | `true` | Allow drag-to-dismiss gesture |
| `dismissesOnOverlayTap` | `true` | Dismiss on overlay tap |
| `dismissVelocityThreshold` | `170` | Velocity needed to dismiss (px/s) |
| `dismissDistanceThreshold` | `100` | Distance needed to dismiss (px) |

## Requirements

- iOS 26+
- Swift 6.1+

## License

Available under the MIT license.
