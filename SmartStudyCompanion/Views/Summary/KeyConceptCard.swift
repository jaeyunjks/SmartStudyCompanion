import SwiftUI

struct KeyConceptCard: View {
    let concept: KeyConcept

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(concept.term)
                .font(.headline.weight(.bold))
                .foregroundStyle(SummaryTheme.accent)

            Text(concept.definition)
                .font(.subheadline)
                .foregroundStyle(SummaryTheme.textSecondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SummaryTheme.secondarySurface.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SummaryTheme.cornerMedium, style: .continuous)
                .stroke(SummaryTheme.accent.opacity(0.10), lineWidth: 1)
        )
    }
}

#Preview {
    KeyConceptCard(concept: StudySummary.previewSummaries[0].keyConcepts[0])
        .padding()
}
