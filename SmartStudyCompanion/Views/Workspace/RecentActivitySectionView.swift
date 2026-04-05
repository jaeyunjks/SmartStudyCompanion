import SwiftUI

struct RecentActivitySectionView: View {
    let items: [ActivityItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2.weight(.bold))

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(WorkspaceTheme.accent.opacity(0.12))
                    .frame(width: 1)
                    .padding(.leading, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                VStack(spacing: 16) {
                    ForEach(items) { item in
                        ActivityTimelineItemView(item: item)
                    }
                }
            }
        }
    }
}

#Preview {
    RecentActivitySectionView(items: [
        .init(iconName: "doc.text", title: "Key Concepts", timestamp: "2h ago", detail: "Short summary."),
        .init(iconName: "photo", title: "Architecture Diagram", timestamp: "3d ago", detail: "Updated diagram.")
    ])
    .padding()
}
