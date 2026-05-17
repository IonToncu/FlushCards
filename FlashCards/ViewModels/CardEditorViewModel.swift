import SwiftData
import Foundation

@MainActor
@Observable
final class CardEditorViewModel {
    var word: String = ""
    var translation: String = ""
    var notes: String = ""
    var examples: [(sentence: String, translation: String)] = []
    var errorMessage: String?

    private let topicId: UUID
    private let existingCard: Card?
    private let cardRepo: CardRepository

    init(topicId: UUID, existingCard: Card? = nil, context: ModelContext) {
        self.topicId = topicId
        self.existingCard = existingCard
        self.cardRepo = CardRepository(context: context)

        if let card = existingCard {
            word = card.word
            translation = card.translation
            notes = card.notes
            examples = card.examples.map { ($0.sentence, $0.translation) }
        }
    }

    func addExampleRow() {
        examples.append((sentence: "", translation: ""))
    }

    func removeExample(at index: Int) {
        examples.remove(at: index)
    }

    var isValid: Bool { !word.trimmingCharacters(in: .whitespaces).isEmpty && !translation.trimmingCharacters(in: .whitespaces).isEmpty }

    func save() {
        guard isValid else { return }
        if let card = existingCard {
            card.word = word.trimmingCharacters(in: .whitespaces)
            card.translation = translation.trimmingCharacters(in: .whitespaces)
            card.notes = notes
            card.examples = examples.map { Example(sentence: $0.sentence, translation: $0.translation) }
        } else {
            let card = Card(topicId: topicId, word: word.trimmingCharacters(in: .whitespaces),
                            translation: translation.trimmingCharacters(in: .whitespaces), notes: notes)
            card.examples = examples.map { Example(sentence: $0.sentence, translation: $0.translation) }
            cardRepo.insert(card)
        }
        do { try cardRepo.save() } catch { errorMessage = error.localizedDescription }
    }
}
