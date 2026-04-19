import SwiftUI

struct StudySpaceCardView: View {
    let space: StudySpace

    private var accent: Color {
        switch space.status {
        case "Active":
            return LibraryTheme.accent
        case "Inactive":
            return Color.gray
        default:
            return LibraryTheme.accent
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: space.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(accent)
                    )

                Spacer()

                Text(space.status)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.14))
                    .clipShape(Capsule())
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(space.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(space.description)
                    .font(.subheadline)
                    .foregroundStyle(LibraryTheme.mutedText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            HStack(spacing: 12) {
                Label("\(space.documentCount)", systemImage: "doc.text")
                Label("\(space.noteCount)", systemImage: "note.text")
                Spacer()
                Text(space.lastUpdated)
                    .font(.caption)
                    .foregroundStyle(LibraryTheme.mutedText)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(LibraryTheme.mutedText)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                    Spacer()
                    Text("\(Int(space.progress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                }

                ProgressView(value: space.progress)
                    .tint(accent)
                    .background(accent.opacity(0.10))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .libraryGlass(cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    StudySpaceCardView(space: StudySpace.sampleData[0])
        .padding()
        .background(LibraryTheme.background)
}
