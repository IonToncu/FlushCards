import SwiftData
import Foundation

struct TopicRepository {
    let context: ModelContext

    func fetchAll() throws -> [Topic] {
        let descriptor = FetchDescriptor<Topic>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func insert(_ topic: Topic) {
        context.insert(topic)
    }

    func delete(_ topic: Topic) throws {
        // cascade delete all cards in the topic
        let topicId = topic.id
        let cardDescriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.topicId == topicId })
        let cards = try context.fetch(cardDescriptor)
        for card in cards {
            try deleteCard(card)
        }
        context.delete(topic)
    }

    private func deleteCard(_ card: Card) throws {
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
