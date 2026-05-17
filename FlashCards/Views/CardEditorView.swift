import SwiftUI
import SwiftData

struct CardEditorView: View {
    let topicId: UUID
    let existingCard: Card?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm: CardEditorViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    editorForm(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(existingCard == nil ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm?.save()
                        dismiss()
                    }
                    .disabled(!(vm?.isValid ?? false))
                }
            }
        }
        .onAppear {
            if vm == nil {
                vm = CardEditorViewModel(topicId: topicId, existingCard: existingCard, context: context)
            }
        }
    }

    @ViewBuilder
    private func editorForm(vm: CardEditorViewModel) -> some View {
        Form {
            Section("Card") {
                TextField("Word", text: Binding(get: { vm.word }, set: { vm.word = $0 }))
                TextField("Translation", text: Binding(get: { vm.translation }, set: { vm.translation = $0 }))
            }
            Section("Notes (optional)") {
                TextField("Notes", text: Binding(get: { vm.notes }, set: { vm.notes = $0 }), axis: .vertical)
                    .lineLimit(3...6)
            }
            Section {
                ForEach(vm.examples.indices, id: \.self) { i in
                    VStack(spacing: 4) {
                        TextField("Sentence", text: Binding(
                            get: { vm.examples[i].sentence },
                            set: { vm.examples[i].sentence = $0 }
                        ))
                        TextField("Translation", text: Binding(
                            get: { vm.examples[i].translation },
                            set: { vm.examples[i].translation = $0 }
                        ))
                        .font(.caption)
                    }
                }
                .onDelete { vm.examples.remove(atOffsets: $0) }
                Button("Add Example") { vm.addExampleRow() }
            } header: {
                Text("Examples")
            }
        }
    }
}
