import Foundation
import SwiftData

@Model
final class Example {
    var id: UUID
    var sentence: String
    var translation: String

    init(sentence: String, translation: String) {
        self.id = UUID()
        self.sentence = sentence
        self.translation = translation
    }
}
