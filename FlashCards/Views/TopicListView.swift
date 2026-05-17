import SwiftUI
import SwiftData

struct TopicListView: View {
    @Environment(\.modelContext) private var context
    @State private var vm: TopicListViewModel?
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    topicContent(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Topics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                if let vm { AddTopicSheet(vm: vm) }
            }
            .onAppear {
                if vm == nil { vm = TopicListViewModel(context: context) }
                vm?.load()
            }
        }
    }

    @ViewBuilder
    private func topicContent(vm: TopicListViewModel) -> some View {
        if vm.topics.isEmpty {
            ContentUnavailableView("No Topics Yet", systemImage: "folder",
                                   description: Text("Tap + to add your first topic."))
        } else {
            List {
                ForEach(vm.topics) { topic in
                    NavigationLink(destination: TopicDetailView(topic: topic)) {
                        TopicRow(topic: topic)
                    }
                }
                .onDelete { offsets in
                    offsets.forEach { vm.deleteTopic(vm.topics[$0]) }
                }
            }
        }
    }
}

private struct TopicRow: View {
    let topic: Topic
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(topic.name).font(.headline)
            Text("\(topic.sourceLanguage) → \(topic.targetLanguage)")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct AddTopicSheet: View {
    let vm: TopicListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var sourceLang = ""
    @State private var targetLang = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    TextField("Name (e.g. Animals)", text: $name)
                }
                Section("Languages") {
                    TextField("Source (e.g. English)", text: $sourceLang)
                    TextField("Target (e.g. Spanish)", text: $targetLang)
                }
            }
            .navigationTitle("New Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addTopic(name: name, sourceLanguage: sourceLang, targetLanguage: targetLang)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
