import SwiftUI

struct AICompanionSectionView: View {
    @Environment(\.workspaceThemePalette) private var palette
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    private let secondaryActions: [AISecondaryAction] = [
        .init(title: "Ask AI", iconName: "message"),
        .init(title: "Quiz", iconName: "questionmark.circle"),
        .init(title: "Flashcards", iconName: "rectangle.stack"),
        .init(title: "Action Plan", iconName: "checklist")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Study Hub")
                        .font(.headline.weight(.bold))
                    Text("Use AI to deepen or test understanding")
                        .font(.caption)
                        .foregroundStyle(WorkspaceTheme.mutedText)
                }

                Spacer()

                Text("5 tools")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(palette.chipBackground)
                    .clipShape(Capsule())
            }

            AIPrimaryActionCardView(title: "Summarise Knowledge", subtitle: "Condense all module notes into a high-level framework.", onTap: onPrimaryAction)

            AISecondaryActionsGridView(actions: secondaryActions, onSelect: { action in
                onSecondaryAction(action.title)
            })
        }
    }
}

struct AISecondaryAction: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

#Preview {
    AICompanionSectionView(onPrimaryAction: {}, onSecondaryAction: { _ in })
        .padding()
}
