import SwiftUI

struct ActivityTimelineItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: ActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: item.iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
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
            .background(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

#Preview {
    ActivityTimelineItemView(item: .init(id: UUID(), iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."))
        .padding()
}
