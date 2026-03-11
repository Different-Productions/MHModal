import XCTest
import SwiftUI
@testable import MHModal

final class ModalAppearanceTests: XCTestCase {
    func testDefaultAppearance() {
        let appearance = ModalAppearance.default

        XCTAssertEqual(appearance.background, Color(.systemBackground))
        XCTAssertEqual(appearance.overlayColor, Color.black.opacity(0.4))
        XCTAssertEqual(appearance.cornerRadius, 38)
        XCTAssertEqual(appearance.horizontalPadding, 20)
        XCTAssertEqual(appearance.bottomPadding, 0)
        XCTAssertTrue(appearance.showDragIndicator)
        XCTAssertEqual(appearance.dragIndicatorColor, Color(.systemGray3))
        XCTAssertEqual(appearance.maxHeightRatio, 0.85)
        XCTAssertEqual(appearance.contentShrinkThreshold, 80)
        XCTAssertEqual(appearance.contentGrowthThreshold, 20)
    }

    func testCardAppearance() {
        let appearance = ModalAppearance.card

        XCTAssertEqual(appearance.cornerRadius, 20)
        XCTAssertEqual(appearance.horizontalPadding, 16)
        XCTAssertEqual(appearance.bottomPadding, 16)
        XCTAssertTrue(appearance.showDragIndicator)
    }

    func testMinimalAppearance() {
        let appearance = ModalAppearance.minimal

        XCTAssertEqual(appearance.cornerRadius, 24)
        XCTAssertFalse(appearance.showDragIndicator)
    }

    func testCustomAppearance() {
        let customAppearance = ModalAppearance(
            background: .blue,
            overlayColor: .red.opacity(0.3),
            cornerRadius: 20,
            horizontalPadding: 30,
            bottomPadding: 25,
            showDragIndicator: false,
            dragIndicatorColor: .green,
            maxHeightRatio: 0.75,
            contentShrinkThreshold: 100,
            contentGrowthThreshold: 10
        )

        XCTAssertEqual(customAppearance.background, .blue)
        XCTAssertEqual(customAppearance.overlayColor, .red.opacity(0.3))
        XCTAssertEqual(customAppearance.cornerRadius, 20)
        XCTAssertEqual(customAppearance.horizontalPadding, 30)
        XCTAssertEqual(customAppearance.bottomPadding, 25)
        XCTAssertFalse(customAppearance.showDragIndicator)
        XCTAssertEqual(customAppearance.dragIndicatorColor, .green)
        XCTAssertEqual(customAppearance.maxHeightRatio, 0.75)
        XCTAssertEqual(customAppearance.contentShrinkThreshold, 100)
        XCTAssertEqual(customAppearance.contentGrowthThreshold, 10)
    }

    func testMaxHeightRatioConstraints() {
        // Test with value greater than 1
        let tooHighValue = ModalAppearance(maxHeightRatio: 1.5)
        XCTAssertEqual(tooHighValue.maxHeightRatio, 1.0)

        // Test with negative value
        let negativeValue = ModalAppearance(maxHeightRatio: -0.5)
        XCTAssertEqual(negativeValue.maxHeightRatio, 0.0)

        // Test with valid value
        let validValue = ModalAppearance(maxHeightRatio: 0.75)
        XCTAssertEqual(validValue.maxHeightRatio, 0.75)
    }

    func testAppearanceEquality() {
        let appearance1 = ModalAppearance(
            background: .blue,
            cornerRadius: 20
        )

        let appearance2 = ModalAppearance(
            background: .blue,
            cornerRadius: 20
        )

        let appearance3 = ModalAppearance(
            background: .red,
            cornerRadius: 20
        )

        XCTAssertEqual(appearance1, appearance2)
        XCTAssertNotEqual(appearance1, appearance3)
    }
}
