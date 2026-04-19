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
        .workspaceSurface(prominence: .tertiary)
    }
}

#Preview {
    RecentActivitySectionView(items: [
        .init(iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."),
        .init(iconName: "photo", title: "Architecture Diagram", timestamp: "3d ago", detail: "Updated diagram.")
    ])
    .padding()
}
