import SwiftData
import Foundation

@MainActor
@Observable
final class TopicListViewModel {
    var topics: [Topic] = []
    var errorMessage: String?

    private let repo: TopicRepository

    init(context: ModelContext) {
        self.repo = TopicRepository(context: context)
    }

    func load() {
        do {
            topics = try repo.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTopic(name: String, sourceLanguage: String, targetLanguage: String) {
        let topic = Topic(name: name, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        repo.insert(topic)
        save()
        load()
    }

    func deleteTopic(_ topic: Topic) {
        do {
            try repo.delete(topic)
            try repo.save()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() {
        do { try repo.save() } catch { errorMessage = error.localizedDescription }
    }
}
