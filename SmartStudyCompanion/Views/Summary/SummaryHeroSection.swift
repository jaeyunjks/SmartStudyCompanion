import SwiftUI

struct SummaryHeroSection: View {
    @Environment(\.summaryPalette) private var palette
    let summary: StudySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(summary.category)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.accentStrong)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(palette.accentSoft)
                    .clipShape(Capsule())

                Text(summary.estimatedReadTime)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
            }

            Text(summary.title)
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundStyle(palette.accent)
                .lineSpacing(2)

            Text(summary.overview)
                .font(.body)
                .foregroundStyle(palette.textSecondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    SummaryHeroSection(summary: StudySummary.previewSummaries[0])
        .padding()
}
