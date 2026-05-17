import SwiftData
import Foundation

@MainActor
@Observable
final class CardListViewModel {
    var cards: [Card] = []
    var errorMessage: String?

    private let topicId: UUID
    private let cardRepo: CardRepository
    private let reviewRepo: ReviewRepository
    private let statsService = StatisticsService()

    var stats: TopicStats?

    init(topicId: UUID, context: ModelContext) {
        self.topicId = topicId
        self.cardRepo = CardRepository(context: context)
        self.reviewRepo = ReviewRepository(context: context)
    }

    func load() {
        do {
            cards = try cardRepo.fetchAll(for: topicId)
            let ids = cards.map(\.id)
            let records = try reviewRepo.allRecords(for: ids)
            stats = statsService.compute(cards: cards, records: records)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCard(_ card: Card) {
        do {
            try cardRepo.delete(card)
            try cardRepo.save()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
