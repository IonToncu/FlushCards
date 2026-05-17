import Foundation
import SwiftData

@Model
final class Card {
    var id: UUID
    var topicId: UUID
    var word: String
    var translation: String
    var notes: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var examples: [Example]

    init(topicId: UUID, word: String, translation: String, notes: String = "") {
        self.id = UUID()
        self.topicId = topicId
        self.word = word
        self.translation = translation
        self.notes = notes
        self.createdAt = Date.now
        self.examples = []
    }
}
