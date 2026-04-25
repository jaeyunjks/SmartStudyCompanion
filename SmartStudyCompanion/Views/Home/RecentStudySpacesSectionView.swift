import SwiftUI

struct RecentStudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Study Workspaces")
                .font(.title3.weight(.bold))

            VStack(spacing: 10) {
                if spaces.isEmpty {
                    RecentWorkspacesEmptyState()
                } else {
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
}

private struct RecentWorkspacesEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No study workspaces yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text("Create your first workspace to start organising notes, materials, and AI tools.")
                .font(.footnote)
                .foregroundStyle(HomeTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeGlass(cornerRadius: HomeTheme.smallCornerRadius)
    }
}

private struct RecentStudySpaceRow: View {
    let space: StudySpace

    private var accent: Color {
        space.workspaceAccentColor
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

            Text(space.normalizedStatus)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(space.statusBackgroundColor)
                .clipShape(Capsule())
                .foregroundStyle(space.statusForegroundColor)
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
