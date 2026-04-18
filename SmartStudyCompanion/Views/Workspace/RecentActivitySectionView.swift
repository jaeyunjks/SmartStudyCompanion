import SwiftUI

struct RecentActivitySectionView: View {
    let items: [ActivityItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.title3.weight(.bold))

            VStack(spacing: 10) {
                ForEach(items) { item in
                    ActivityTimelineItemView(item: item)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                .stroke(WorkspaceTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    RecentActivitySectionView(items: [
        .init(iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."),
        .init(iconName: "photo", title: "Architecture Diagram", timestamp: "3d ago", detail: "Updated diagram.")
    ])
    .padding()
}
