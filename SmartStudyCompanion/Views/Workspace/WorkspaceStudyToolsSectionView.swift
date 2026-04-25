import SwiftUI

struct WorkspaceStudyToolsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let onCreateNote: () -> Void
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Capture notes instantly, then turn them into summaries, quizzes, flashcards, and plans.")
                .font(.caption)
                .foregroundStyle(WorkspaceTheme.mutedText)

            Button(action: onCreateNote) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(colorScheme == .dark ? 0.14 : 0.28))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Create Note")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Capture ideas quickly and keep momentum")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [
                            palette.primaryStrong.opacity(colorScheme == .dark ? 0.96 : 1),
                            palette.primary.opacity(colorScheme == .dark ? 0.88 : 0.96),
                            palette.primaryStrong.opacity(colorScheme == .dark ? 0.95 : 0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: palette.primaryStrong.opacity(0.24), radius: 16, x: 0, y: 9)
            }
            .buttonStyle(WorkspacePressableButtonStyle())

            Text("AI Tools")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(WorkspaceTheme.mutedText)

            AICompanionSectionView(
                onPrimaryAction: onPrimaryAction,
                onSecondaryAction: onSecondaryAction
            )
        }
        .padding(16)
        .workspaceSurface(prominence: .primary)
    }
}

#Preview {
    WorkspaceStudyToolsSectionView(onCreateNote: {}, onPrimaryAction: {}, onSecondaryAction: { _ in })
        .padding()
}
