import SwiftData
import Foundation

@MainActor
@Observable
final class StudyViewModel {
    var currentCard: Card?
    var isFlipped: Bool = false
    var currentIndex: Int = 0
    var totalCount: Int = 0
    var errorMessage: String?

    private var cards: [Card] = []

    init(topicId: UUID, context: ModelContext) {
        let repo = CardRepository(context: context)
        do {
            cards = try repo.fetchAll(for: topicId).shuffled()
            totalCount = cards.count
            currentCard = cards.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func flip() { isFlipped = true }

    func next() {
        guard currentIndex < cards.count - 1 else { return }
        currentIndex += 1
        currentCard = cards[currentIndex]
        isFlipped = false
    }

    func previous() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        currentCard = cards[currentIndex]
        isFlipped = false
    }

    var hasNext: Bool { currentIndex < cards.count - 1 }
    var hasPrevious: Bool { currentIndex > 0 }
}
