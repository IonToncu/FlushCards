import SwiftUI

struct CardDetailView: View {
    let card: Card
    @State private var isFlipped = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FlipCardView(card: card, isFlipped: $isFlipped)
                    .frame(height: 220)
                    .padding(.horizontal)

                if isFlipped && !card.examples.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples").font(.headline)
                        ForEach(card.examples) { example in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(example.sentence).font(.body)
                                Text(example.translation).font(.caption).foregroundStyle(.secondary)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }

                if isFlipped && !card.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes").font(.headline)
                        Text(card.notes).font(.body).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                if !isFlipped {
                    Button("Reveal Translation") { withAnimation(.spring) { isFlipped = true } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top)
        }
        .navigationTitle(card.word)
        .navigationBarTitleDisplayMode(.inline)
    }
}
