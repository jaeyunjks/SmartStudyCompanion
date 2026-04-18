import SwiftUI

struct WorkspaceTopBarView: View {
    let title: String
    let onBack: () -> Void
    let onMore: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(WorkspaceTheme.accent)
                .lineLimit(1)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorkspaceTheme.accent)
                        .frame(width: 36, height: 36)
                        .background(WorkspaceTheme.accentSoft.opacity(0.9))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.92))
    }
}

#Preview {
    WorkspaceTopBarView(title: "Active Study Workspace", onBack: {}, onMore: {})
}
