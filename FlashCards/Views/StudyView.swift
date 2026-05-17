import SwiftUI
import SwiftData

struct StudyView: View {
    let topic: Topic
    @Environment(\.modelContext) private var context
    @State private var vm: StudyViewModel?

    var body: some View {
        Group {
            if let vm {
                if let card = vm.currentCard {
                    studyContent(vm: vm, card: card)
                } else {
                    ContentUnavailableView("No Cards", systemImage: "tray",
                                           description: Text("Add cards to start studying."))
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Study: \(topic.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if vm == nil { vm = StudyViewModel(topicId: topic.id, context: context) }
        }
    }

    @ViewBuilder
    private func studyContent(vm: StudyViewModel, card: Card) -> some View {
        VStack(spacing: 24) {
            Text("\(vm.currentIndex + 1) / \(vm.totalCount)")
                .font(.caption).foregroundStyle(.secondary)

            FlipCardView(card: card, isFlipped: .constant(vm.isFlipped))
                .frame(height: 220)
                .padding(.horizontal)
                .onTapGesture { vm.flip() }

            if vm.isFlipped && !card.examples.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(card.examples) { ex in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ex.sentence)
                                Text(ex.translation).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 150)
            }

            Spacer()

            HStack(spacing: 20) {
                Button { vm.previous() } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(vm.hasPrevious ? .blue : .gray)
                }
                .disabled(!vm.hasPrevious)

                Button { vm.next() } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(vm.hasNext ? .blue : .gray)
                }
                .disabled(!vm.hasNext)
            }
            .padding(.bottom, 32)
        }
    }
}
