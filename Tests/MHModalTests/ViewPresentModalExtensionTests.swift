import Testing
import SwiftUI
@testable import MHModal

@MainActor
struct ViewPresentModalExtensionTests {

    private let baseView = Text("Base View")
    private let dismissedBinding = Binding<Bool>(get: { false }, set: { _ in })
    private let presentedBinding = Binding<Bool>(get: { true }, set: { _ in })

    // MARK: - Core Overloads

    @Test func presentModalBasicAPI() {
        _ = baseView.presentModal(isPresented: dismissedBinding) {
            Text("Modal Content")
        }
    }

    @Test func presentModalWithAppearance() {
        _ = baseView.presentModal(
            isPresented: dismissedBinding,
            appearance: .minimal
        ) {
            Text("Minimal Modal Content")
        }
    }

    @Test func presentModalWithBehavior() {
        _ = baseView.presentModal(
            isPresented: dismissedBinding,
            behavior: .nonDismissible
        ) {
            Text("Non-dismissible Modal Content")
        }
    }

    @Test func presentModalWithFullCustomization() {
        _ = baseView.presentModal(
            isPresented: dismissedBinding,
            appearance: .minimal,
            behavior: .easyDismiss
        ) {
            VStack {
                Text("Fully Customized Modal")
                Button("Action") { }
            }
        }
    }

    // MARK: - Convenience Modifiers

    @Test func presentCardModal() {
        _ = baseView.presentCardModal(isPresented: dismissedBinding) {
            Text("Card Modal Content")
        }
    }

    @Test func presentMinimalModal() {
        _ = baseView.presentMinimalModal(isPresented: dismissedBinding) {
            Text("Minimal Modal Content")
        }
    }

    @Test func presentSheetModal() {
        _ = baseView.presentSheetModal(isPresented: dismissedBinding) {
            Text("Sheet Modal Content")
        }
    }

    // MARK: - Phase-Based API

    @Test func presentModalWithPhase() {
        _ = baseView.presentModal(
            isPresented: presentedBinding,
            phase: 0
        ) { step in
            switch step {
            case 0: Text("Step 1")
            case 1: Text("Step 2")
            default: Text("Done")
            }
        }
    }

    @Test func presentModalWithPhaseAndCustomTransition() {
        _ = baseView.presentModal(
            isPresented: presentedBinding,
            phase: "welcome",
            appearance: .card,
            behavior: .nonDismissible,
            transition: .modalSlideForward
        ) { phase in
            switch phase {
            case "welcome": Text("Welcome")
            case "details": Text("Details")
            default: Text("Unknown")
            }
        }
    }
}
