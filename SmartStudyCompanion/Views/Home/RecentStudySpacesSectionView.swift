import SwiftUI

struct RecentStudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onViewAll: () -> Void
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Study Workspaces")
                    .font(.title3.weight(.bold))

                Spacer()

                Button("View all", action: onViewAll)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(HomeTheme.accent)
            }

            VStack(spacing: 10) {
                if spaces.isEmpty {
                    RecentWorkspacesEmptyState()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(spaces.prefix(3))) { space in
                                Button(action: { onSelect(space) }) {
                                    RecentStudySpaceCard(space: space)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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

private struct RecentStudySpaceCard: View {
    let space: StudySpace

    private var accent: Color {
        space.workspaceAccentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: space.iconName)
                            .foregroundStyle(accent)
                            .font(.system(size: 14, weight: .semibold))
                    )
                    .shadow(color: accent.opacity(0.12), radius: 6, x: 0, y: 4)

                Spacer()

                Text(space.normalizedStatus)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(space.statusBackgroundColor)
                    .clipShape(Capsule())
                    .foregroundStyle(space.statusForegroundColor)
            }

            Text(space.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(space.lastUpdated)
                .font(.caption)
                .foregroundStyle(HomeTheme.mutedText)
                .lineLimit(1)
        }
        .frame(width: 164, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .homeGlass(cornerRadius: HomeTheme.smallCornerRadius)
    }
}

#Preview {
    RecentStudySpacesSectionView(
        spaces: Array(StudySpace.sampleData.suffix(3)),
        onViewAll: {},
        onSelect: { _ in }
    )
        .padding()
        .background(HomeTheme.background)
}
