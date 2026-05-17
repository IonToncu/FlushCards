import XCTest
@testable import FlashCards
import SwiftData

final class SRSEngineTests: XCTestCase {
    var container: ModelContainer!
    var engine: SRSEngine!

    override func setUp() {
        super.setUp()
        container = FlashCardsStore.makeInMemory()
        engine = SRSEngine()
    }

    func testGoodRatingIncreasesInterval() {
        let record = ReviewRecord(cardId: UUID())
        container.mainContext.insert(record)
        let updated = engine.nextReview(record: record, rating: .good)
        XCTAssertGreaterThan(updated.interval, 1.0)
        XCTAssertEqual(updated.repetitions, 1)
        XCTAssertGreaterThan(updated.easeFactor, 2.5)
    }

    func testBadRatingResetsInterval() {
        let record = ReviewRecord(cardId: UUID())
        record.interval = 10
        record.repetitions = 5
        container.mainContext.insert(record)
        let updated = engine.nextReview(record: record, rating: .bad)
        XCTAssertEqual(updated.interval, 1.0)
        XCTAssertEqual(updated.repetitions, 0)
        XCTAssertLessThan(updated.easeFactor, 2.5)
    }

    func testOkayRatingModerateIncrease() {
        let record = ReviewRecord(cardId: UUID())
        record.interval = 4
        container.mainContext.insert(record)
        let updated = engine.nextReview(record: record, rating: .okay)
        XCTAssertGreaterThan(updated.interval, 1.0)
        XCTAssertLessThan(updated.interval, 4 * 2.5)
        XCTAssertEqual(updated.repetitions, 1)
    }

    func testEaseFactorMinimumClamped() {
        let record = ReviewRecord(cardId: UUID())
        record.easeFactor = 1.3
        container.mainContext.insert(record)
        let updated = engine.nextReview(record: record, rating: .bad)
        XCTAssertEqual(updated.easeFactor, 1.3, accuracy: 0.001)
    }

    func testDueDateIsInFuture() {
        let record = ReviewRecord(cardId: UUID())
        container.mainContext.insert(record)
        let before = Date.now
        let updated = engine.nextReview(record: record, rating: .good)
        XCTAssertGreaterThan(updated.dueDate, before)
    }
}
