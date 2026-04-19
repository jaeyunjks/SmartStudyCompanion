import SwiftUI

struct AISecondaryActionsGridView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let actions: [AISecondaryAction]
    let onSelect: (AISecondaryAction) -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(actions) { action in
                Button(action: { onSelect(action) }) {
                    VStack(alignment: .leading, spacing: 10) {
                        Circle()
                            .fill(palette.iconBackground)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: action.iconName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(palette.primary)
                            )

                        Text(action.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WorkspaceTheme.surfaceSecondary(for: colorScheme).opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
                .buttonStyle(WorkspacePressableButtonStyle())
            }
        }
    }
}

#Preview {
    AISecondaryActionsGridView(actions: [
        .init(title: "Ask AI", iconName: "message"),
        .init(title: "Quiz", iconName: "questionmark.circle")
    ], onSelect: { _ in })
    .padding()
}
