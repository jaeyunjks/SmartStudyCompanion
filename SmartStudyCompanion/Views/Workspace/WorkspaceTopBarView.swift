import SwiftUI

struct WorkspaceTopBarView: View {
    let title: String
    let onBack: () -> Void
    let onMore: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(WorkspaceTheme.accentSoft)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(WorkspaceTheme.accent)

            Spacer()

            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(WorkspaceTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    WorkspaceTopBarView(title: "Active Study Workspace", onBack: {}, onMore: {})
}
