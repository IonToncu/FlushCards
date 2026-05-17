import Foundation
import SwiftData

@Model
final class ReviewRecord {
    var id: UUID
    var cardId: UUID
    var interval: Double       // days
    var easeFactor: Double
    var repetitions: Int
    var dueDate: Date
    var lastResult: Rating
    var lastReviewedAt: Date

    enum Rating: String, Codable {
        case bad, okay, good
    }

    init(cardId: UUID) {
        self.id = UUID()
        self.cardId = cardId
        self.interval = 1
        self.easeFactor = 2.5
        self.repetitions = 0
        self.dueDate = Date.now
        self.lastResult = .okay
        self.lastReviewedAt = Date.now
    }
}
