import SwiftUI

struct AIPrimaryActionCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.16 : 0.26))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? palette.primarySoft : .white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(colorScheme == .dark ? .white : palette.primaryStrong)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.86) : palette.primaryStrong.opacity(0.82))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.9) : palette.primaryStrong.opacity(0.85))
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [palette.primaryStrong.opacity(0.9), palette.primary.opacity(0.7)]
                        : [palette.primarySoft.opacity(0.65), palette.chipBackground.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                    .stroke(palette.primary.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: palette.primary.opacity(0.14), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(WorkspacePressableButtonStyle())
    }
}

#Preview {
    AIPrimaryActionCardView(title: "Summarise Knowledge", subtitle: "Condense all module notes into a high-level framework.", onTap: {})
        .padding()
}
