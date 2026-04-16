import SwiftUI

struct SummaryTopBar: View {
    let isBookmarked: Bool
    let shareText: String
    let onBack: () -> Void
    let onToggleBookmark: () -> Void
    let onFallbackShare: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                topButton(iconName: "chevron.left", action: onBack)

                Text("Summary")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(SummaryTheme.accent)
            }

            Spacer()

            HStack(spacing: 8) {
                topButton(iconName: isBookmarked ? "bookmark.fill" : "bookmark", action: onToggleBookmark)
                SummaryShareButton(shareText: shareText, onFallbackShare: onFallbackShare)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(SummaryTheme.background.opacity(0.85))
        .background(.ultraThinMaterial)
    }

    private func topButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(SummaryTheme.accent)
                .frame(width: 36, height: 36)
                .background(SummaryTheme.accentSoft.opacity(0.8))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct SummaryShareButton: View {
    let shareText: String
    let onFallbackShare: () -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            ShareLink(item: shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SummaryTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(SummaryTheme.accentSoft.opacity(0.8))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        } else {
            Button(action: onFallbackShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SummaryTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(SummaryTheme.accentSoft.opacity(0.8))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SummaryTopBar(
        isBookmarked: false,
        shareText: "Example summary",
        onBack: {},
        onToggleBookmark: {},
        onFallbackShare: {}
    )
}
