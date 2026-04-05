import SwiftUI

struct StudySpaceCardView: View {
    let space: StudySpace

    private var accent: Color {
        switch space.status {
        case "Active", "In Progress", "Priority":
            return LibraryTheme.accent
        case "Review":
            return Color(red: 0.20, green: 0.53, blue: 0.56)
        case "Completed":
            return Color.gray
        default:
            return LibraryTheme.accent
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: space.iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(accent)
                    )

                Spacer()

                Text(space.status)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.16))
                    .clipShape(Capsule())
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(space.title)
                    .font(.headline)

                Text(space.description)
                    .font(.subheadline)
                    .foregroundStyle(LibraryTheme.mutedText)
                    .lineLimit(3)
            }

            HStack(spacing: 12) {
                Label("\(space.documentCount) documents", systemImage: "doc.text")
                Label("\(space.noteCount) notes", systemImage: "note.text")

                Spacer()

                Text(space.lastUpdated)
                    .font(.caption)
                    .foregroundStyle(LibraryTheme.mutedText)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(LibraryTheme.mutedText)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: LibraryTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LibraryTheme.cardCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    StudySpaceCardView(space: StudySpace.sampleData[0])
        .padding()
        .background(LibraryTheme.background)
}
