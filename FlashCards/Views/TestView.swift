import SwiftUI
import SwiftData

struct TestView: View {
    let topic: Topic
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm: TestViewModel?

    var body: some View {
        Group {
            if let vm {
                if vm.sessionComplete {
                    sessionCompleteView
                } else if let card = vm.currentCard {
                    testContent(vm: vm, card: card)
                } else {
                    ProgressView()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Test: \(topic.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if vm == nil {
                vm = TestViewModel(topicId: topic.id, context: context)
                vm?.startSession()
            }
        }
    }

    private var sessionCompleteView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("Session Complete!").font(.title).bold()
            Text("Great work. Come back later to review more cards.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    @ViewBuilder
    private func testContent(vm: TestViewModel, card: Card) -> some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(vm.remainingCount) remaining")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            FlipCardView(card: card, isFlipped: .constant(vm.isFlipped))
                .frame(height: 220)
                .padding(.horizontal)
                .onTapGesture { vm.flip() }

            if vm.isFlipped {
                if !card.examples.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Examples").font(.subheadline).bold()
                            ForEach(card.examples) { ex in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.sentence)
                                    Text(ex.translation).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 120)
                }

                ratingButtons(vm: vm)
            } else {
                Button("Show Answer") {
                    withAnimation(.spring) { vm.flip() }
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(.top)
    }

    private func ratingButtons(vm: TestViewModel) -> some View {
        VStack(spacing: 8) {
            Text("How well did you know this?").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 16) {
                RatingButton(label: "Bad", systemImage: "xmark.circle.fill", color: .red) {
                    vm.rate(.bad)
                }
                RatingButton(label: "Okay", systemImage: "minus.circle.fill", color: .orange) {
                    vm.rate(.okay)
                }
                RatingButton(label: "Good", systemImage: "checkmark.circle.fill", color: .green) {
                    vm.rate(.good)
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct RatingButton: View {
    let label: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 36))
                Text(label).font(.caption).bold()
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
