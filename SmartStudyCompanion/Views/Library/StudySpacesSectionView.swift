import SwiftUI

struct StudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void
    var onCreateFirst: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("My Study Workspaces")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)

            if spaces.isEmpty {
                LibraryEmptyStateView(onCreateFirst: onCreateFirst)
            } else {
                VStack(spacing: 12) {
                    ForEach(spaces) { space in
                        Button(action: { onSelect(space) }) {
                            StudySpaceCardView(space: space)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct LibraryEmptyStateView: View {
    let onCreateFirst: (() -> Void)?

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            Circle()
                .fill(LibraryTheme.accentSoft.opacity(0.9))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "books.vertical")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LibraryTheme.accent)
                )

            VStack(spacing: 6) {
                Text("No study workspaces yet")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("Create your first study workspace to organise notes, materials, and AI tools in one place.")
                    .font(.footnote)
                    .foregroundStyle(LibraryTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Button(action: { onCreateFirst?() }) {
                Text("Create your first study workspace")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        LinearGradient(
                            colors: [LibraryTheme.accent, LibraryTheme.accent.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .libraryGlass(cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    StudySpacesSectionView(spaces: StudySpace.sampleData, onSelect: { _ in })
        .padding()
        .background(LibraryTheme.background)
}
