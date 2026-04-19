import SwiftUI

struct FlashcardRevealHint: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap")
                .font(.footnote.weight(.semibold))
            Text("Tap to reveal answer")
                .font(.footnote.weight(.medium))
        }
        .foregroundStyle(FlashcardSessionTheme.mutedText)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(FlashcardSessionTheme.surfaceStrong.opacity(0.7))
        .clipShape(Capsule())
    }
}

#Preview {
    FlashcardRevealHint()
        .padding()
}
