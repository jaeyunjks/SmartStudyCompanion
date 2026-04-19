import SwiftUI

struct WorkspaceStudyToolsSectionView: View {
    let onCreateNote: () -> Void
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study Tools")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(WorkspaceTheme.deepAccent)
                .textCase(.uppercase)
                .tracking(0.8)

            Button(action: onCreateNote) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(WorkspaceTheme.accentSoft)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(WorkspaceTheme.deepAccent)
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
                .padding(14)
                .background(
                    LinearGradient(
                        colors: [WorkspaceTheme.deepAccent, WorkspaceTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            AICompanionSectionView(
                onPrimaryAction: onPrimaryAction,
                onSecondaryAction: onSecondaryAction
            )
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                .stroke(WorkspaceTheme.accent.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: WorkspaceTheme.accent.opacity(0.05), radius: 14, x: 0, y: 8)
    }
}

#Preview {
    WorkspaceStudyToolsSectionView(onCreateNote: {}, onPrimaryAction: {}, onSecondaryAction: { _ in })
        .padding()
}
