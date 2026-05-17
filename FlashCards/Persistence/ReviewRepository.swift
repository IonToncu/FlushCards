import SwiftData
import Foundation

struct ReviewRepository {
    let context: ModelContext

    func record(for cardId: UUID) throws -> ReviewRecord? {
        let descriptor = FetchDescriptor<ReviewRecord>(predicate: #Predicate { $0.cardId == cardId })
        return try context.fetch(descriptor).first
    }

    func dueCards(in topicId: UUID, cardIds: [UUID]) throws -> [UUID] {
        let now = Date.now
        let descriptor = FetchDescriptor<ReviewRecord>(
            predicate: #Predicate { $0.dueDate <= now }
        )
        let due = try context.fetch(descriptor).filter { cardIds.contains($0.cardId) }
        let dueIds = Set(due.map(\.cardId))
        // cards with no review record are also due
        let neverReviewed = cardIds.filter { id in
            let d = FetchDescriptor<ReviewRecord>(predicate: #Predicate { $0.cardId == id })
            return (try? context.fetch(d).isEmpty) ?? true
        }
        return cardIds.filter { dueIds.contains($0) || neverReviewed.contains($0) }
    }

    func upsert(_ record: ReviewRecord) {
        if context.registeredModel(for: record.persistentModelID) == nil {
            context.insert(record)
        }
    }

    func save() throws {
        try context.save()
    }

    // Statistics helpers
    func allRecords(for cardIds: [UUID]) throws -> [ReviewRecord] {
        let descriptor = FetchDescriptor<ReviewRecord>(
            predicate: #Predicate { record in cardIds.contains(record.cardId) }
        )
        return try context.fetch(descriptor)
    }
}
