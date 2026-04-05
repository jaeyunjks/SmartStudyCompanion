import SwiftUI

struct AIPrimaryActionCardView: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
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
