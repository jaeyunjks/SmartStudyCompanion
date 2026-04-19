import SwiftUI

struct RecentStudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Study Spaces")
                .font(.title3.weight(.bold))

            VStack(spacing: 10) {
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
        case "Active":
            return HomeTheme.accent
        case "Inactive":
            return Color.gray
        default:
            return HomeTheme.accent
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: space.iconName)
                        .foregroundStyle(accent)
                        .font(.system(size: 16, weight: .semibold))
                )
                .shadow(color: accent.opacity(0.12), radius: 6, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(space.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .homeGlass(cornerRadius: HomeTheme.smallCornerRadius)
    }
}

#Preview {
    RecentStudySpacesSectionView(spaces: Array(StudySpace.sampleData.suffix(3)), onSelect: { _ in })
        .padding()
        .background(HomeTheme.background)
}
