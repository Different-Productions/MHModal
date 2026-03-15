import Testing
import SwiftUI
@testable import MHModal

struct ModalBehaviorTests {

    @Test func defaultBehavior() {
        let behavior = ModalBehavior.default

        #expect(behavior.enableDragToDismiss == true)
        #expect(behavior.tapToDismiss == true)
        #expect(behavior.dismissVelocityThreshold == 170)
        #expect(behavior.dismissDistanceThreshold == 100)
    }

    @Test func nonDismissibleBehavior() {
        let behavior = ModalBehavior.nonDismissible

        #expect(behavior.enableDragToDismiss == false)
        #expect(behavior.tapToDismiss == false)
        #expect(behavior.dismissVelocityThreshold == 170)
        #expect(behavior.dismissDistanceThreshold == 100)
    }

    @Test func easyDismissBehavior() {
        let behavior = ModalBehavior.easyDismiss

        #expect(behavior.enableDragToDismiss == true)
        #expect(behavior.tapToDismiss == true)
        #expect(behavior.dismissVelocityThreshold == 100)
        #expect(behavior.dismissDistanceThreshold == 50)
    }

    @Test func customBehavior() {
        let customBehavior = ModalBehavior(
            enableDragToDismiss: false,
            tapToDismiss: false,
            dismissVelocityThreshold: 200,
            dismissDistanceThreshold: 150
        )

        #expect(customBehavior.enableDragToDismiss == false)
        #expect(customBehavior.tapToDismiss == false)
        #expect(customBehavior.dismissVelocityThreshold == 200)
        #expect(customBehavior.dismissDistanceThreshold == 150)
    }

    @Test func equality() {
        let behavior1 = ModalBehavior(enableDragToDismiss: false, dismissVelocityThreshold: 200)
        let behavior2 = ModalBehavior(enableDragToDismiss: false, dismissVelocityThreshold: 200)
        let behavior3 = ModalBehavior(enableDragToDismiss: true, dismissVelocityThreshold: 200)

        #expect(behavior1 == behavior2)
        #expect(behavior1 != behavior3)
    }
}
