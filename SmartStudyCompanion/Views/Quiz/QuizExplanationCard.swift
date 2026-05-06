import SwiftUI

struct QuizExplanationCard: View {
    @Environment(\.quizPalette) private var palette

    let isCorrect: Bool
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isCorrect ? "Correct" : "Not quite")
                .font(.headline.weight(.bold))
                .foregroundStyle(isCorrect ? palette.accent : palette.error)

            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke((isCorrect ? palette.accent : palette.error).opacity(0.28), lineWidth: 1)
        )
    }
}

#Preview {
    QuizExplanationCard(isCorrect: true, explanation: "Cloud allows on-demand provisioning.")
        .padding()
}