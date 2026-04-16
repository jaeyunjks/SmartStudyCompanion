import SwiftUI

struct SummaryHeroSection: View {
    let summary: StudySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(summary.category)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SummaryTheme.accentStrong)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(SummaryTheme.accentSoft)
                    .clipShape(Capsule())

                Text(summary.estimatedReadTime)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SummaryTheme.textSecondary)
            }

            Text(summary.title)
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundStyle(SummaryTheme.accent)
                .lineSpacing(2)

            Text(summary.overview)
                .font(.body)
                .foregroundStyle(SummaryTheme.textSecondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    SummaryHeroSection(summary: StudySummary.mockSummaries[0])
        .padding()
}
