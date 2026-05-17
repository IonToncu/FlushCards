import SwiftData
import Foundation

struct CardRepository {
    let context: ModelContext

    func fetchAll(for topicId: UUID) throws -> [Card] {
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.topicId == topicId },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    func insert(_ card: Card) {
        context.insert(card)
    }

    func delete(_ card: Card) throws {
        let cardId = card.id
        let rrDescriptor = FetchDescriptor<ReviewRecord>(predicate: #Predicate { $0.cardId == cardId })
        let records = try context.fetch(rrDescriptor)
        for r in records { context.delete(r) }
        context.delete(card)
    }

    func save() throws {
        try context.save()
    }
}
