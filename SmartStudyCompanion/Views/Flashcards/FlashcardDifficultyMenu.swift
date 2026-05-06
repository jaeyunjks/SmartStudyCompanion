import SwiftUI

struct FlashcardDifficultyMenu: View {
    let selectedDifficulty: FlashcardDifficulty
    let onSelect: (FlashcardDifficulty) -> Void

    var body: some View {
        Menu {
            ForEach(FlashcardDifficulty.allCases) { difficulty in
                Button(action: { onSelect(difficulty) }) {
                    HStack {
                        Text(difficulty.rawValue)
                        if difficulty == selectedDifficulty {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FlashcardSessionTheme.accent)
                .frame(width: 42, height: 42)
                .background(FlashcardSessionTheme.surface)
                .clipShape(Circle())
        }
    }
}

#Preview {
    FlashcardDifficultyMenu(selectedDifficulty: .showAll, onSelect: { _ in })
        .padding()
}
