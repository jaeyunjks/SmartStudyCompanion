import SwiftUI

struct RecentStudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Study Spaces")
                .font(.title2.weight(.bold))

            VStack(spacing: 12) {
                ForEach(spaces) { space in
                    Button(action: { onSelect(space) }) {
                        RecentStudySpaceRow(space: space)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct RecentStudySpaceRow: View {
    let space: StudySpace

    private var accent: Color {
        switch space.status {
        case "Active", "In Progress":
            return HomeTheme.accent
        case "Review":
            return Color.orange
        case "Completed":
            return Color.gray
        default:
            return HomeTheme.accent
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: space.iconName)
                        .foregroundStyle(accent)
                        .font(.system(size: 16, weight: .semibold))
                )
                .shadow(color: accent.opacity(0.12), radius: 6, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(space.title)
                    .font(.headline)
                Text(space.lastUpdated)
                    .font(.caption)
                    .foregroundStyle(HomeTheme.mutedText)
            }

            Spacer()

            Text(space.status)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(accent.opacity(0.12))
                .clipShape(Capsule())
                .foregroundStyle(accent)
        }
        .padding(14)
        .background(HomeTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: HomeTheme.smallCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeTheme.smallCornerRadius, style: .continuous)
                .stroke(accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    RecentStudySpacesSectionView(spaces: Array(StudySpace.sampleData.suffix(3)), onSelect: { _ in })
        .padding()
        .background(HomeTheme.background)
}
