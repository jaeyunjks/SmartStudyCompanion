import SwiftUI

struct StudyPlanHeader: View {
    let workspaceName: String
    let completionText: String
    let topicBadge: String
    let supportiveMessage: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workspaceName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(StudyPlanTheme.mutedText)

            Text(completionText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(StudyPlanTheme.accent)

            Text(topicBadge)
                .font(.caption.weight(.semibold))
                .foregroundStyle(StudyPlanTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(StudyPlanTheme.accentSoft.opacity(0.78))
                .clipShape(Capsule())

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(StudyPlanTheme.surface)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [StudyPlanTheme.accent, StudyPlanTheme.accentSoft],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * max(0.02, progress))
                }
            }
            .frame(height: 12)

            Text(supportiveMessage)
                .font(.footnote)
                .foregroundStyle(StudyPlanTheme.mutedText)
                .lineSpacing(2)
        }
    }
}

#Preview {
    StudyPlanHeader(
        workspaceName: "Linen & Moss",
        completionText: "35% Complete",
        topicBadge: "Cloud Fundamentals",
        supportiveMessage: "Great momentum so far.",
        progress: 0.35
    )
    .padding()
}
