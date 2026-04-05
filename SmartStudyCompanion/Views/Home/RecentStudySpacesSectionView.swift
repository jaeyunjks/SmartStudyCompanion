import SwiftUI

struct RecentStudySpacesSectionView: View {
    private let spaces: [RecentStudySpace] = [
        .init(title: "Biology 101", subtitle: "Edited 2h ago", status: "Completed", icon: "leaf", accent: HomeTheme.accent),
        .init(title: "Macroeconomics", subtitle: "Edited yesterday", status: "Active", icon: "chart.line.uptrend.xyaxis", accent: Color.blue),
        .init(title: "French Literature", subtitle: "Edited 3 days ago", status: "Review", icon: "book.closed", accent: Color.orange)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Study Spaces")
                .font(.title2.weight(.bold))

            VStack(spacing: 12) {
                ForEach(spaces) { space in
                    RecentStudySpaceRow(space: space)
                }
            }
        }
    }
}

private struct RecentStudySpace: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let icon: String
    let accent: Color
}

private struct RecentStudySpaceRow: View {
    let space: RecentStudySpace

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: space.icon)
                        .foregroundStyle(space.accent)
                        .font(.system(size: 16, weight: .semibold))
                )
                .shadow(color: space.accent.opacity(0.12), radius: 6, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(space.title)
                    .font(.headline)
                Text(space.subtitle)
                    .font(.caption)
                    .foregroundStyle(HomeTheme.mutedText)
            }

            Spacer()

            Text(space.status)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(space.accent.opacity(0.12))
                .clipShape(Capsule())
                .foregroundStyle(space.accent)
        }
        .padding(14)
        .background(HomeTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: HomeTheme.smallCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeTheme.smallCornerRadius, style: .continuous)
                .stroke(space.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    RecentStudySpacesSectionView()
        .padding()
        .background(HomeTheme.background)
}
