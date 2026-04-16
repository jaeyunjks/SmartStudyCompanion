import SwiftUI

struct ImportantPointsCard: View {
    let points: [ImportantPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Important Points")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                    Text(attributedText(for: point))
                        .font(.system(size: 19, weight: .regular, design: .rounded))
                        .lineSpacing(4)
                        .padding(.leading, index == 0 ? 10 : 0)
                        .background(alignment: .leading) {
                            if index == 0 {
                                Capsule()
                                    .fill(SummaryTheme.accent)
                                    .frame(width: 4)
                            }
                        }
                }
            }
            .padding(20)
            .summaryGlassCard()
        }
    }

    private func attributedText(for point: ImportantPoint) -> AttributedString {
        var result = AttributedString(point.text)

        for phrase in point.highlights {
            if let range = result.range(of: phrase, options: .caseInsensitive) {
                result[range].font = .system(size: 17, weight: .semibold, design: .rounded)
                result[range].foregroundColor = SummaryTheme.accentStrong
                result[range].backgroundColor = SummaryTheme.accentSoft.opacity(0.90)
            }
        }

        return result
    }
}

#Preview {
    ImportantPointsCard(points: StudySummary.mockSummaries[0].importantPoints)
        .padding()
}
