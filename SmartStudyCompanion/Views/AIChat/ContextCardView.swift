import SwiftUI

struct ContextCardView: View {
    let context: WorkspaceContext

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AIChatTheme.accentSoft.opacity(0.65))
                .frame(height: 150)
                .overlay {
                    Image(systemName: context.previewSystemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90)
                        .foregroundStyle(AIChatTheme.accent.opacity(0.45))
                }

            LinearGradient(
                colors: [.clear, AIChatTheme.accent.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(context.visualLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("\(context.workspaceTitle) • \(context.sourceType)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.86))
            }
            .padding(14)
        }
        .shadow(color: AIChatTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

#Preview {
    ContextCardView(context: .mockCloudContext)
        .padding()
}
