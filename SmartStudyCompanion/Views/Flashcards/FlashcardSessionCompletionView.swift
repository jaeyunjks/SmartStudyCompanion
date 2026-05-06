import SwiftUI

struct FlashcardSessionCompletionView: View {
    let summary: FlashcardSessionSummary
    let onRestart: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Session Complete")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(FlashcardSessionTheme.accent)

            VStack(spacing: 10) {
                statRow(title: "Total Cards", value: "\(summary.totalCards)")
                statRow(title: "Got It", value: "\(summary.knownCards)")
                statRow(title: "Review Again", value: "\(summary.reviewAgainCards)")
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(FlashcardSessionTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(spacing: 12) {
                Button("Close", action: onClose)
                    .buttonStyle(.bordered)

                Button("Restart Session", action: onRestart)
                    .buttonStyle(.borderedProminent)
                    .tint(FlashcardSessionTheme.accent)
            }
        }
        .padding(.horizontal, 20)
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(FlashcardSessionTheme.mutedText)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(FlashcardSessionTheme.accent)
        }
    }
}

#Preview {
    FlashcardSessionCompletionView(
        summary: FlashcardSessionSummary(totalCards: 10, knownCards: 7, reviewAgainCards: 3),
        onRestart: {},
        onClose: {}
    )
    .padding()
}
