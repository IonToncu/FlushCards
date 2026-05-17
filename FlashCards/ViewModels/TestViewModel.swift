import SwiftData
import Foundation

@MainActor
@Observable
final class TestViewModel {
    var currentCard: Card?
    var isFlipped: Bool = false
    var sessionComplete: Bool = false
    var remainingCount: Int = 0
    var errorMessage: String?

    private var queue: [Card] = []
    private let engine = SRSEngine()
    private let cardRepo: CardRepository
    private let reviewRepo: ReviewRepository
    private let topicId: UUID

    init(topicId: UUID, context: ModelContext) {
        self.topicId = topicId
        self.cardRepo = CardRepository(context: context)
        self.reviewRepo = ReviewRepository(context: context)
    }

    func startSession() {
        do {
            let allCards = try cardRepo.fetchAll(for: topicId)
            let allIds = allCards.map(\.id)
            let dueIds = try reviewRepo.dueCards(in: topicId, cardIds: allIds)
            queue = allCards.filter { dueIds.contains($0.id) }.shuffled()
            remainingCount = queue.count
            advance()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func flip() {
        isFlipped = true
    }

    func rate(_ rating: ReviewRecord.Rating) {
        guard let card = currentCard else { return }
        do {
            let existing = try reviewRepo.record(for: card.id)
            let record = existing ?? ReviewRecord(cardId: card.id)
            _ = engine.nextReview(record: record, rating: rating)
            reviewRepo.upsert(record)
            try reviewRepo.save()
        } catch {
            errorMessage = error.localizedDescription
        }
        advance()
    }

    private func advance() {
        if queue.isEmpty {
            currentCard = nil
            sessionComplete = true
        } else {
            currentCard = queue.removeFirst()
            remainingCount = queue.count + 1
            isFlipped = false
        }
    }
}
