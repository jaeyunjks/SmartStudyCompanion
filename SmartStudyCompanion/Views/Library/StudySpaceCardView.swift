import SwiftUI

struct StudySpaceCardView: View {
    let space: StudySpace

    private var accent: Color {
        space.workspaceAccentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: space.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accent)
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

            VStack(alignment: .leading, spacing: 4) {
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
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .libraryGlass(cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    StudySpaceCardView(space: StudySpace.sampleData[0])
        .padding()
        .background(LibraryTheme.background)
}
