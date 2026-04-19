import SwiftUI

struct QuizProgressView: View {
    let progress: QuizProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PROGRESS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(QuizTheme.accent)

                Spacer()

                Text("Question \(progress.current) of \(progress.total)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(QuizTheme.surfaceStrong)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [QuizTheme.accent, QuizTheme.accentSoft],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress.fractionCompleted)
                }
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    QuizProgressView(progress: QuizProgress(current: 3, total: 10))
        .padding()
}
