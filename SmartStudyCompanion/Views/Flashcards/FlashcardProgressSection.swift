import SwiftUI

struct FlashcardProgressSection: View {
    let progressText: String
    let moduleLabel: String
    let progressValue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(progressText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(FlashcardSessionTheme.accent)

            Text(moduleLabel)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FlashcardSessionTheme.mutedText)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(FlashcardSessionTheme.surfaceStrong)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [FlashcardSessionTheme.accent, FlashcardSessionTheme.accentSoft],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * max(0.02, progressValue))
                }
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    FlashcardProgressSection(progressText: "5 of 20", moduleLabel: "Cloud Infrastructure Module", progressValue: 0.25)
        .padding()
}
