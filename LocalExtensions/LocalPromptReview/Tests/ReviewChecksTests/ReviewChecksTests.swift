import XCTest
@testable import ReviewChecks

final class ReviewChecksTests: XCTestCase {
    func testDroppedWithoutApplyingFromActualHoldoutIsFlagged() {
        let flags = ReviewChecks.warnings(original: "Set the timeout to 300 milliseconds, not 3 seconds. Keep retries at 2. Describe the change without applying it.", proposed: "Set the timeout to exactly 300 milliseconds, not 3 seconds. Keep retries at exactly 2. Describe the change.")
        XCTAssertTrue(flags.contains { $0.contains("negative phrases") })
    }
    func testChangedUnitsCannotBeCertifiedByNumericChecks() {
        // Same numbers can conceal a unit error: this limitation must stay explicit.
        XCTAssertTrue(ReviewChecks.warnings(original: "Use 300 milliseconds.", proposed: "Use 300 seconds.").isEmpty)
    }
    func testChangedCountIsFlagged() {
        XCTAssertTrue(ReviewChecks.warnings(original: "Use 3 retries.", proposed: "Use 5 retries.").contains { $0.contains("Numbers changed") })
    }
    func testDroppedScopeIsFlagged() {
        XCTAssertEqual(ReviewChecks.warnings(original: "Use only my notes in exactly 4 bullets.", proposed: "Use my notes in 4 bullets.").count, 2)
    }
    func testCaseSensitiveIdentifiersAndPathsArePreserved() {
        let flags = ReviewChecks.warnings(original: "Read /tmp/input.csv and keep customer_id.", proposed: "Read /tmp/output.csv and keep customerId.")
        XCTAssertTrue(flags.contains { $0.contains("/tmp/input.csv") && $0.contains("customer_id") })
    }
    func testFaithfulRewriteDoesNotWarn() {
        XCTAssertTrue(ReviewChecks.warnings(original: "Please do not deploy. Return exactly 3 findings.", proposed: "Do not deploy. Return exactly 3 findings.").isEmpty)
    }
    func testEmptyOutputOffersOriginalRecovery() {
        XCTAssertTrue(ReviewChecks.warnings(original: "Explain the error.", proposed: " \n").contains { $0.contains("empty") })
    }
}
