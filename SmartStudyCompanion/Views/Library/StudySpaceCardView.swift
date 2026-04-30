import SwiftUI

struct StudySpaceCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let space: StudySpace

    private var accent: Color {
        space.workspaceAccentColor
    }

    private var iconBackgroundOpacity: Double {
        colorScheme == .dark ? 0.26 : 0.22
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(iconBackgroundOpacity))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: space.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accent.opacity(0.95))
                    )

                Spacer()

                Text(space.normalizedStatus)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(space.statusBackgroundColor)
                    .clipShape(Capsule())
                    .foregroundStyle(space.statusForegroundColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(space.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(space.description)
                    .font(.footnote)
                    .foregroundStyle(LibraryTheme.mutedText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            HStack(spacing: 14) {
                Label("\(space.documentCount)", systemImage: "doc.text")
                    .labelStyle(.titleAndIcon)
                Label("\(space.noteCount)", systemImage: "note.text")
                    .labelStyle(.titleAndIcon)
                Spacer()
                Text(space.lastUpdated)
                    .font(.caption)
                    .foregroundStyle(LibraryTheme.mutedText)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(LibraryTheme.mutedText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .workspaceTintCard(accent: accent, cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    StudySpaceCardView(space: StudySpace.sampleData[0])
        .padding()
        .background(LibraryTheme.background)
}
