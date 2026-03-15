import Testing
import SwiftUI
@testable import MHModal

@MainActor
struct MorphingModalTests {

    @Test func initialization() {
        let coordinator = ModalCoordinator()
        // Verify modal can be constructed without errors
        _ = MorphingModal(coordinator: coordinator) {
            Text("Test Content")
        }
    }

    @Test func initializationWithCustomCoordinator() {
        let coordinator = ModalCoordinator(appearance: .minimal, behavior: .nonDismissible)

        _ = MorphingModal(coordinator: coordinator) {
            VStack {
                Text("Custom Content")
                Button("Action") { }
            }
        }
    }

    @Test func bodyRendersWhenPresented() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = true

        let modal = MorphingModal(coordinator: coordinator) {
            Text("Test Content")
        }

        // Access body to verify it renders without error
        _ = modal.body
    }

    @Test func bodyRendersWhenNotPresented() {
        let coordinator = ModalCoordinator()
        coordinator.isPresented = false

        let modal = MorphingModal(coordinator: coordinator) {
            Text("Hidden Content")
        }

        _ = modal.body
    }
}
