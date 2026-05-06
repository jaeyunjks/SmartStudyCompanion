import SwiftUI

struct SummaryActionButtons: View {
    @Environment(\.summaryPalette) private var palette
    let isLoading: Bool
    let onRegenerate: () -> Void
    let onSimplify: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRegenerate) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(palette.accent)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }

                    Text(isLoading ? "Regenerating..." : "Regenerate")
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(palette.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 27, style: .continuous)
                        .stroke(palette.accent.opacity(0.45), lineWidth: 1.8)
                )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Button(action: onSimplify) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Simplify")
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(palette.accent)
                .clipShape(Capsule())
                .shadow(color: palette.accent.opacity(0.20), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .scaleEffect(isLoading ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
    }
}

#Preview {
    SummaryActionButtons(isLoading: false, onRegenerate: {}, onSimplify: {})
        .padding()
}
