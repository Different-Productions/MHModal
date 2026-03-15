import Testing
import SwiftUI
@testable import MHModal

@MainActor
struct ModalContentTransitionTests {

    @Test func initializationWithIntPhase() {
        _ = ModalContentTransition(phase: 0) { step in
            switch step {
            case 0: Text("Step 1")
            case 1: Text("Step 2")
            default: Text("Done")
            }
        }
    }

    @Test func initializationWithStringPhase() {
        _ = ModalContentTransition(phase: "welcome") { phase in
            Text("Phase: \(phase)")
        }
    }

    @Test func initializationWithCustomTransition() {
        _ = ModalContentTransition(
            phase: 1,
            transition: .modalSlideForward
        ) { step in
            Text("Step \(step)")
        }
    }

    @Test func bodyRenders() {
        let transition = ModalContentTransition(phase: 0) { _ in
            Text("Content")
        }

        _ = transition.body
    }
}
