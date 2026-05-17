import SwiftUI
import SwiftData

struct TopicDetailView: View {
    let topic: Topic
    @Environment(\.modelContext) private var context
    @State private var vm: CardListViewModel?
    @State private var showingEditor = false
    @State private var selectedCard: Card?

    var body: some View {
        Group {
            if let vm {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingEditor = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingEditor, onDismiss: { vm?.load() }) {
            CardEditorView(topicId: topic.id, existingCard: nil)
        }
        .sheet(item: $selectedCard, onDismiss: { vm?.load() }) { card in
            CardEditorView(topicId: topic.id, existingCard: card)
        }
        .onAppear {
            if vm == nil { vm = CardListViewModel(topicId: topic.id, context: context) }
            vm?.load()
        }
    }

    @ViewBuilder
    private func content(vm: CardListViewModel) -> some View {
        List {
            if let stats = vm.stats {
                Section {
                    StatsRowView(stats: stats)
                }
            }
            Section("Actions") {
                NavigationLink(destination: StudyView(topic: topic)) {
                    Label("Study All", systemImage: "book")
                }
                NavigationLink(destination: TestView(topic: topic)) {
                    Label("Test (Due Cards)", systemImage: "checkmark.circle")
                }
            }
            Section("Cards (\(vm.cards.count))") {
                if vm.cards.isEmpty {
                    Text("No cards yet. Tap + to add one.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.cards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardRowView(card: card)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { vm.deleteCard(card) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button { selectedCard = card } label: {
                                Label("Edit", systemImage: "pencil")
                            }.tint(.blue)
                        }
                    }
                }
            }
        }
    }
}

private struct CardRowView: View {
    let card: Card
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(card.word).font(.body)
            Text(card.translation).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct StatsRowView: View {
    let stats: TopicStats
    var body: some View {
        HStack(spacing: 20) {
            statItem(value: "\(stats.totalCards)", label: "Cards")
            statItem(value: "\(stats.dueCount)", label: "Due")
            statItem(value: "\(Int(stats.retentionRate * 100))%", label: "Retention")
            statItem(value: String(format: "%.1f", stats.averageEaseFactor), label: "Ease")
        }
        .frame(maxWidth: .infinity)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack {
            Text(value).font(.title2).bold()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
