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
                    .fill(palette.iconBackground)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.primary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(WorkspacePressableButtonStyle())
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(uiColor: .secondarySystemBackground)
            : Color(red: 0.97, green: 0.98, blue: 0.975)
    }
}

#Preview {
    AIPrimaryActionCardView(title: "Summarise Knowledge", subtitle: "Condense all module notes into a high-level framework.", onTap: {})
        .padding()
}
