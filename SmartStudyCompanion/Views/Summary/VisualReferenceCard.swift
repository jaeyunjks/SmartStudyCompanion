import SwiftUI

struct VisualReferenceCard: View {
    let title: String
    let caption: String
    let imageName: String?
    let imageSystemName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous)
                .fill(SummaryTheme.secondarySurface)
                .overlay {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [SummaryTheme.accentSoft.opacity(0.55), SummaryTheme.secondarySurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            Image(systemName: imageSystemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)
                                .foregroundStyle(SummaryTheme.accent.opacity(0.5))
                        }
                    }
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous))

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.36)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(caption)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.88))
                    .textCase(.uppercase)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(20)
        }
        .shadow(color: SummaryTheme.cardShadow, radius: 16, x: 0, y: 8)
    }
}

#Preview {
    VisualReferenceCard(
        title: StudySummary.mockSummaries[0].visualReferenceTitle,
        caption: StudySummary.mockSummaries[0].visualReferenceCaption,
        imageName: nil,
        imageSystemName: StudySummary.mockSummaries[0].imageSystemName
    )
    .padding()
}
