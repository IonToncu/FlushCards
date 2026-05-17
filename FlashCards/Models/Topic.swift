import Foundation
import SwiftData

@Model
final class Topic {
    var id: UUID
    var name: String
    var sourceLanguage: String
    var targetLanguage: String
    var createdAt: Date

    init(name: String, sourceLanguage: String, targetLanguage: String) {
        self.id = UUID()
        self.name = name
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.createdAt = Date.now
    }
}
