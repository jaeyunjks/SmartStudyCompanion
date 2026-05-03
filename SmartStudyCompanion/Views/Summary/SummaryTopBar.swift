import SwiftUI

struct SummaryTopBar: View {
    @Environment(\.summaryPalette) private var palette
    let shareText: String
    let onBack: () -> Void
    let onFallbackShare: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                topButton(iconName: "chevron.left", action: onBack)

                Text("Summary")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.accent)
            }

            Spacer()

            SummaryShareButton(shareText: shareText, onFallbackShare: onFallbackShare)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(palette.background.opacity(0.85))
        .background(.ultraThinMaterial)
    }

    private func topButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 36, height: 36)
                .background(palette.accentSoft.opacity(0.8))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct SummaryShareButton: View {
    @Environment(\.summaryPalette) private var palette

    let shareText: String
    let onFallbackShare: () -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            ShareLink(item: shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 36, height: 36)
                    .background(palette.accentSoft.opacity(0.8))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        } else {
            Button(action: onFallbackShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 36, height: 36)
                    .background(palette.accentSoft.opacity(0.8))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SummaryTopBar(
        shareText: "Example summary",
        onBack: {},
        onFallbackShare: {}
    )
}
