import SwiftData
import Foundation

@MainActor
final class FlashCardsStore {
    static let shared = FlashCardsStore()

    let container: ModelContainer

    private init() {
        let schema = Schema([Topic.self, Card.self, Example.self, ReviewRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    static func makeInMemory() -> ModelContainer {
        let schema = Schema([Topic.self, Card.self, Example.self, ReviewRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }
}
