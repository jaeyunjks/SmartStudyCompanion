import SwiftUI

struct WorkspaceTopBarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let title: String
    let onBack: () -> Void
    let onMore: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(palette.primary)
                .lineLimit(1)

            HStack {
                Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(palette.primary)
                            .frame(width: 36, height: 36)
                            .background(palette.iconBackground)
                            .clipShape(Circle())
                    }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.primary)
                        .frame(width: 36, height: 36)
                        .background(WorkspaceTheme.secondaryBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            WorkspaceTheme.background
                .opacity(colorScheme == .dark ? 0.84 : 0.72)
                .blur(radius: 0)
        )
    }
}

#Preview {
    WorkspaceTopBarView(title: "Active Study Workspace", onBack: {}, onMore: {})
}
