import SwiftUI

struct FlipCardView: View {
    let card: Card
    @Binding var isFlipped: Bool

    private var rotation: Double { isFlipped ? 180 : 0 }

    var body: some View {
        ZStack {
            frontFace
                .opacity(isFlipped ? 0 : 1)
            backFace
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(duration: 0.4), value: isFlipped)
        .onTapGesture { isFlipped.toggle() }
    }

    private var frontFace: some View {
        cardBackground(color: .blue.opacity(0.85)) {
            VStack(spacing: 8) {
                Text("Word").font(.caption).foregroundStyle(.white.opacity(0.7))
                Text(card.word)
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var backFace: some View {
        cardBackground(color: .green.opacity(0.85)) {
            VStack(spacing: 8) {
                Text("Translation").font(.caption).foregroundStyle(.white.opacity(0.7))
                Text(card.translation)
                    .font(.title2).bold()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func cardBackground<Content: View>(color: Color, @ViewBuilder content: () -> Content) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(color)
            .shadow(radius: 8)
            .overlay(content())
    }
}
