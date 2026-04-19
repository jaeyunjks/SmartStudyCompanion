import SwiftUI

struct WorkspaceStudyToolsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let onCreateNote: () -> Void
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Study Tools")
                .font(.headline.weight(.bold))
                .foregroundStyle(palette.primaryStrong)

            Button(action: onCreateNote) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(palette.iconBackground)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(palette.primaryStrong)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create Note")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Capture insights while you study")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.92))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            palette.primaryStrong,
                            palette.primary.opacity(colorScheme == .dark ? 0.92 : 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: palette.primaryStrong.opacity(0.22), radius: 14, x: 0, y: 8)
            }
            .buttonStyle(WorkspacePressableButtonStyle())

            Text("AI support")
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
