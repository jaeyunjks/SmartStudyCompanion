import SwiftUI

struct MainIdeasCard: View {
    let ideas: [SummaryMainIdea]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Main Ideas")

            VStack(alignment: .leading, spacing: 16) {
                ForEach(ideas) { idea in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(SummaryTheme.accent)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)

                        Text(idea.text)
                            .font(.body.italic())
                            .foregroundStyle(.primary.opacity(0.88))
                            .lineSpacing(4)
                    }
                }
            }
            .padding(20)
            .summaryGlassCard()
        }
    }

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Spacer()

            Capsule()
                .fill(SummaryTheme.accentSoft)
                .frame(width: 46, height: 5)
        }
    }
}

#Preview {
    MainIdeasCard(ideas: StudySummary.previewSummaries[0].mainIdeas)
        .padding()
}
