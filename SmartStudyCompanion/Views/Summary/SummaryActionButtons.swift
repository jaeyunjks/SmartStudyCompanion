import SwiftUI

struct SummaryActionButtons: View {
    let isLoading: Bool
    let onRegenerate: () -> Void
    let onSimplify: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRegenerate) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(SummaryTheme.accent)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }

                    Text(isLoading ? "Regenerating..." : "Regenerate")
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(SummaryTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 27, style: .continuous)
                        .stroke(SummaryTheme.accent.opacity(0.45), lineWidth: 1.8)
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
                .background(SummaryTheme.accent)
                .clipShape(Capsule())
                .shadow(color: SummaryTheme.accent.opacity(0.24), radius: 12, x: 0, y: 8)
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
