import Testing
import SwiftUI
@testable import MHModal

struct ModalAppearanceTests {

    @Test func defaultAppearance() {
        let appearance = ModalAppearance.default
        let expectedBackground = Color(UIColor.systemBackground)
        let expectedIndicatorColor = Color(UIColor.systemGray3)

        #expect(appearance.background == expectedBackground)
        #expect(appearance.overlayColor == Color.black.opacity(0.4))
        #expect(appearance.cornerRadius == 38)
        #expect(appearance.horizontalPadding == 8)
        #expect(appearance.bottomPadding == 0)
        #expect(appearance.showsDragIndicator == true)
        #expect(appearance.dragIndicatorColor == expectedIndicatorColor)
        #expect(appearance.maxHeightRatio == 0.85)
    }

    @Test func cardAppearance() {
        let appearance = ModalAppearance.card

        #expect(appearance.cornerRadius == 20)
        #expect(appearance.horizontalPadding == 16)
        #expect(appearance.bottomPadding == 16)
        #expect(appearance.showsDragIndicator == true)
    }

    @Test func minimalAppearance() {
        let appearance = ModalAppearance.minimal

        #expect(appearance.cornerRadius == 24)
        #expect(appearance.showsDragIndicator == false)
    }

    @Test func sheetAppearance() {
        let appearance = ModalAppearance.sheet

        #expect(appearance.cornerRadius == 20)
        #expect(appearance.horizontalPadding == 0)
        #expect(appearance.showsDragIndicator == true)
    }

    @Test func customAppearance() {
        let customAppearance = ModalAppearance(
            background: .blue,
            overlayColor: .red.opacity(0.3),
            cornerRadius: 20,
            horizontalPadding: 30,
            bottomPadding: 25,
            showsDragIndicator: false,
            dragIndicatorColor: .green,
            maxHeightRatio: 0.75
        )

        #expect(customAppearance.background == .blue)
        #expect(customAppearance.overlayColor == .red.opacity(0.3))
        #expect(customAppearance.cornerRadius == 20)
        #expect(customAppearance.horizontalPadding == 30)
        #expect(customAppearance.bottomPadding == 25)
        #expect(customAppearance.showsDragIndicator == false)
        #expect(customAppearance.dragIndicatorColor == .green)
        #expect(customAppearance.maxHeightRatio == 0.75)
    }

    @Test(arguments: [
        (input: CGFloat(1.5), expected: CGFloat(1.0)),
        (input: CGFloat(-0.5), expected: CGFloat(0.0)),
        (input: CGFloat(0.75), expected: CGFloat(0.75)),
        (input: CGFloat(0.0), expected: CGFloat(0.0)),
        (input: CGFloat(1.0), expected: CGFloat(1.0)),
    ])
    func maxHeightRatioClamping(input: CGFloat, expected: CGFloat) {
        let appearance = ModalAppearance(maxHeightRatio: input)
        #expect(appearance.maxHeightRatio == expected, "maxHeightRatio \(input) should clamp to \(expected)")
    }

    @Test func equality() {
        let appearance1 = ModalAppearance(background: .blue, cornerRadius: 20)
        let appearance2 = ModalAppearance(background: .blue, cornerRadius: 20)
        let appearance3 = ModalAppearance(background: .red, cornerRadius: 20)

        #expect(appearance1 == appearance2)
        #expect(appearance1 != appearance3)
    }
}
