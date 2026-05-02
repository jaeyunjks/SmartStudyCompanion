import SwiftUI

struct AICompanionSectionView: View {
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (String) -> Void

    private let secondaryActions: [AISecondaryAction] = [
        .init(title: "Ask AI", subtitle: "Get help from Lumora", iconName: "message"),
        .init(title: "Quiz", subtitle: "Practice key concepts", iconName: "questionmark.circle"),
        .init(title: "Flashcards", subtitle: "Memorize faster", iconName: "rectangle.stack"),
        .init(title: "Action Plan", subtitle: "Plan next study steps", iconName: "checklist")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AIPrimaryActionCardView(
                title: "Summarise Knowledge",
                subtitle: "Condense your notes into a clear, high-level summary.",
                onTap: onPrimaryAction
            )

            AISecondaryActionsGridView(actions: secondaryActions, onSelect: { action in
                onSecondaryAction(action.title)
            })
        }
    }
}

struct AISecondaryAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
}

#Preview {
    AICompanionSectionView(onPrimaryAction: {}, onSecondaryAction: { _ in })
        .padding()
}
