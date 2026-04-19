import SwiftUI

struct FlashcardActionButtons: View {
    let isEnabled: Bool
    let onReviewAgain: () -> Void
    let onGotIt: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onReviewAgain) {
                Text("Review again")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(FlashcardSessionTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(FlashcardSessionTheme.surface)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(FlashcardSessionTheme.accent.opacity(0.25), lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.45)

            Button(action: onGotIt) {
                Text("Got it")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(FlashcardSessionTheme.accent)
                    .clipShape(Capsule())
                    .shadow(color: FlashcardSessionTheme.accent.opacity(0.24), radius: 12, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.45)
        }
    }
}

#Preview {
    FlashcardActionButtons(isEnabled: true, onReviewAgain: {}, onGotIt: {})
        .padding()
}
