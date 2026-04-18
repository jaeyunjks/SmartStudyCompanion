import SwiftUI

struct AISecondaryActionsGridView: View {
    let actions: [AISecondaryAction]
    let onSelect: (AISecondaryAction) -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(actions) { action in
                Button(action: { onSelect(action) }) {
                    VStack(alignment: .leading, spacing: 10) {
                        Circle()
                            .fill(WorkspaceTheme.accentSoft.opacity(0.95))
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: action.iconName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(WorkspaceTheme.accent)
                            )

                        Text(action.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WorkspaceTheme.secondaryBackground.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                        .stroke(WorkspaceTheme.accent.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
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
