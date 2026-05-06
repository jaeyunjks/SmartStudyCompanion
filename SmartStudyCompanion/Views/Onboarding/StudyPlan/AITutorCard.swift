import SwiftUI

struct AITutorCard: View {
    let onStartChat: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(StudyPlanTheme.accentSoft)
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: "sparkles")
                        .foregroundStyle(StudyPlanTheme.accent)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("Need a refresher?")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(StudyPlanTheme.accent)
                Text("Ask the AI tutor to break down your weak areas before your next quiz.")
                    .font(.footnote)
                    .foregroundStyle(StudyPlanTheme.mutedText)
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            Button("Start Chat", action: onStartChat)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(StudyPlanTheme.accent)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(StudyPlanTheme.surface)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: StudyPlanTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

#Preview {
    AITutorCard(onStartChat: {})
        .padding()
}
