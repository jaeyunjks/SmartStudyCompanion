import SwiftUI

struct AIPrimaryActionCardView: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.white.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [WorkspaceTheme.accent, WorkspaceTheme.accent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
            .shadow(color: WorkspaceTheme.accent.opacity(0.18), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AIPrimaryActionCardView(title: "Summarise Knowledge", subtitle: "Condense all module notes into a high-level framework.", onTap: {})
        .padding()
}
