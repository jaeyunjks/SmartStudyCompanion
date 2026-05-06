import SwiftUI

struct FlashcardCardView: View {
    let card: FlashcardItem
    let isRevealed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                frontCard
                    .opacity(isRevealed ? 0 : 1)
                    .rotation3DEffect(.degrees(isRevealed ? 180 : 0), axis: (x: 0, y: 1, z: 0))

                backCard
                    .opacity(isRevealed ? 1 : 0)
                    .rotation3DEffect(.degrees(isRevealed ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 460)
            .background(FlashcardSessionTheme.surface)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(FlashcardSessionTheme.accent.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: FlashcardSessionTheme.shadow, radius: 22, x: 0, y: 16)
            .animation(.spring(response: 0.45, dampingFraction: 0.88), value: isRevealed)
        }
        .buttonStyle(.plain)
    }

    private var frontCard: some View {
        VStack(spacing: 20) {
            header

            Spacer()

            Text(card.frontText)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            FlashcardRevealHint()
        }
        .padding(24)
    }

    private var backCard: some View {
        VStack(spacing: 20) {
            header

            Spacer()

            Text(card.backText)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(FlashcardSessionTheme.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Text("Answer")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FlashcardSessionTheme.mutedText)
        }
        .padding(24)
    }

    private var header: some View {
        HStack {
            Label(card.type.rawValue, systemImage: card.type.iconName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FlashcardSessionTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(FlashcardSessionTheme.accentSoft.opacity(0.7))
                .clipShape(Capsule())

            Spacer()
        }
    }
}

#Preview {
    FlashcardCardView(
        card: FlashcardItem(type: .definition, frontText: "Define elasticity.", backText: "Scale resources with demand.", difficulty: .beginner, module: "Cloud Infrastructure"),
        isRevealed: false,
        onTap: {}
    )
    .padding()
}
