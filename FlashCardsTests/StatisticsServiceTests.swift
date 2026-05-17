import XCTest
@testable import FlashCards
import SwiftData

final class StatisticsServiceTests: XCTestCase {
    let service = StatisticsService()
    var container: ModelContainer!

    override func setUp() {
        super.setUp()
        container = FlashCardsStore.makeInMemory()
    }

    func testDueCountIncludesNeverReviewedCards() {
        let topicId = UUID()
        let card = Card(topicId: topicId, word: "hello", translation: "hola")
        container.mainContext.insert(card)
        let stats = service.compute(cards: [card], records: [])
        XCTAssertEqual(stats.dueCount, 1)
    }

    func testRetentionRateWithAllGood() {
        let topicId = UUID()
        let card = Card(topicId: topicId, word: "hello", translation: "hola")
        container.mainContext.insert(card)
        let record = ReviewRecord(cardId: card.id)
        record.lastResult = .good
        record.lastReviewedAt = Date.now
        let stats = service.compute(cards: [card], records: [record])
        XCTAssertEqual(stats.retentionRate, 1.0, accuracy: 0.001)
    }

    func testRetentionRateWithAllBad() {
        let topicId = UUID()
        let card = Card(topicId: topicId, word: "hello", translation: "hola")
        container.mainContext.insert(card)
        let record = ReviewRecord(cardId: card.id)
        record.lastResult = .bad
        record.lastReviewedAt = Date.now
        let stats = service.compute(cards: [card], records: [record])
        XCTAssertEqual(stats.retentionRate, 0.0, accuracy: 0.001)
    }
}
