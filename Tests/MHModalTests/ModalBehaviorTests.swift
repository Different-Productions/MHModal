import Testing
import SwiftUI
@testable import MHModal

struct ModalBehaviorTests {

    @Test func defaultBehavior() {
        let behavior = ModalBehavior.default

        #expect(behavior.isDragToDismissEnabled == true)
        #expect(behavior.dismissesOnOverlayTap == true)
        #expect(behavior.dismissVelocityThreshold == 170)
        #expect(behavior.dismissDistanceThreshold == 100)
    }

    @Test func nonDismissibleBehavior() {
        let behavior = ModalBehavior.nonDismissible

        #expect(behavior.isDragToDismissEnabled == false)
        #expect(behavior.dismissesOnOverlayTap == false)
        #expect(behavior.dismissVelocityThreshold == 170)
        #expect(behavior.dismissDistanceThreshold == 100)
    }

    @Test func easyDismissBehavior() {
        let behavior = ModalBehavior.easyDismiss

        #expect(behavior.isDragToDismissEnabled == true)
        #expect(behavior.dismissesOnOverlayTap == true)
        #expect(behavior.dismissVelocityThreshold == 100)
        #expect(behavior.dismissDistanceThreshold == 50)
    }

    @Test func customBehavior() {
        let customBehavior = ModalBehavior(
            isDragToDismissEnabled: false,
            dismissesOnOverlayTap: false,
            dismissVelocityThreshold: 200,
            dismissDistanceThreshold: 150
        )

        #expect(customBehavior.isDragToDismissEnabled == false)
        #expect(customBehavior.dismissesOnOverlayTap == false)
        #expect(customBehavior.dismissVelocityThreshold == 200)
        #expect(customBehavior.dismissDistanceThreshold == 150)
    }

    @Test func equality() {
        let behavior1 = ModalBehavior(isDragToDismissEnabled: false, dismissVelocityThreshold: 200)
        let behavior2 = ModalBehavior(isDragToDismissEnabled: false, dismissVelocityThreshold: 200)
        let behavior3 = ModalBehavior(isDragToDismissEnabled: true, dismissVelocityThreshold: 200)

        #expect(behavior1 == behavior2)
        #expect(behavior1 != behavior3)
    }
}
