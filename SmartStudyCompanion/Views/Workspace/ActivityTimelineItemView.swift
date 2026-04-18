import SwiftUI

struct ActivityTimelineItemView: View {
    let item: ActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(WorkspaceTheme.accentSoft.opacity(0.85))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: item.iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WorkspaceTheme.accent)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(item.timestamp)
                        .font(.caption)
                        .foregroundStyle(WorkspaceTheme.mutedText)
                }

                Text(item.detail)
                    .font(.footnote)
                    .foregroundStyle(WorkspaceTheme.mutedText)
                    .lineLimit(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorkspaceTheme.secondaryBackground.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

#Preview {
    ActivityTimelineItemView(item: .init(iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."))
        .padding()
}
