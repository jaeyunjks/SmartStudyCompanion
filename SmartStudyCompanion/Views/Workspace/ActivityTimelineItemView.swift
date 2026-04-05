import SwiftUI

struct ActivityTimelineItemView: View {
    let item: ActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(WorkspaceTheme.cardBackground)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: item.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorkspaceTheme.accent)
                )
                .overlay(
                    Circle().stroke(WorkspaceTheme.accent.opacity(0.15), lineWidth: 1)
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
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                    .stroke(WorkspaceTheme.accent.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ActivityTimelineItemView(item: .init(iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."))
        .padding()
}