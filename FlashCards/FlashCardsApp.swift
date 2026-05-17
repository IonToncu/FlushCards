import SwiftUI
import SwiftData

@main
struct FlashCardsApp: App {
    var body: some Scene {
        WindowGroup {
            TopicListView()
        }
        .modelContainer(FlashCardsStore.shared.container)
    }
}
