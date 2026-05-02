import SwiftUI

struct KeyConceptCard: View {
    @Environment(\.summaryPalette) private var palette
    let concept: KeyConcept

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(concept.term)
                .font(.headline.weight(.bold))
                .foregroundStyle(palette.accent)

            Text(concept.definition)
                .font(.subheadline)
                .foregroundStyle(palette.textSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.secondarySurface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SummaryTheme.cornerMedium, style: .continuous)
                .stroke(palette.accent.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    KeyConceptCard(concept: StudySummary.previewSummaries[0].keyConcepts[0])
        .padding()
}
