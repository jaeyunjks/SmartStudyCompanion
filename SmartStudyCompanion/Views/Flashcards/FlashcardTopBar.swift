import SwiftUI

struct FlashcardTopBar: View {
    let selectedDifficulty: FlashcardDifficulty
    let onBack: () -> Void
    let onSelectDifficulty: (FlashcardDifficulty) -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(FlashcardSessionTheme.accent)
                    .frame(width: 42, height: 42)
                    .background(FlashcardSessionTheme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Flashcard Session")
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(FlashcardSessionTheme.accent)

            Spacer()

            FlashcardDifficultyMenu(selectedDifficulty: selectedDifficulty, onSelect: onSelectDifficulty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(FlashcardSessionTheme.accentSoft.opacity(0.42))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, 12)
        .shadow(color: FlashcardSessionTheme.shadow, radius: 14, x: 0, y: 8)
    }
}

#Preview {
    FlashcardTopBar(selectedDifficulty: .showAll, onBack: {}, onSelectDifficulty: { _ in })
        .padding()
}
