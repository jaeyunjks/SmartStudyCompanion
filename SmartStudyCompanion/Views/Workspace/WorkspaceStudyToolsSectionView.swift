import SwiftUI

struct WorkspaceStudyToolsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette

    let onCreateNote: () -> Void
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("CAPTURE")

            Button(action: onCreateNote) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(palette.iconBackground)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(palette.primary)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Note")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Capture ideas quickly and keep momentum")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(WorkspacePressableButtonStyle())

            sectionLabel("AI ASSIST")

            AICompanionSectionView(
                onPrimaryAction: onPrimaryAction,
                onSecondaryAction: onSecondaryAction
            )
        }
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(uiColor: .secondarySystemBackground)
            : Color(red: 0.97, green: 0.985, blue: 0.975)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1.1)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    WorkspaceStudyToolsSectionView(onCreateNote: {}, onPrimaryAction: {}, onSecondaryAction: { _ in })
        .padding()
}
