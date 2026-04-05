import SwiftUI

struct QuickActionsChipsView: View {
    let actions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(actions, id: \.self) { action in
                    Button(action: { onSelect(action) }) {
                        HStack(spacing: 8) {
                            Image(systemName: iconName(for: action))
                                .font(.system(size: 14, weight: .semibold))
                            Text(action)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(tint(for: action))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func iconName(for title: String) -> String {
        switch title {
        case "Review Flashcards":
            return "bolt.fill"
        case "Continue Summary":
            return "doc.text"
        case "Take a Quiz":
            return "questionmark.circle"
        case "AI Insights":
            return "sparkles"
        default:
            return "sparkles"
        }
    }

    private func tint(for title: String) -> Color {
        switch title {
        case "Review Flashcards":
            return Color(red: 0.86, green: 0.94, blue: 0.89)
        case "Continue Summary":
            return Color(red: 0.88, green: 0.94, blue: 0.85)
        case "Take a Quiz":
            return Color(red: 0.86, green: 0.93, blue: 0.95)
        case "AI Insights":
            return Color(red: 0.94, green: 0.96, blue: 0.93)
        default:
            return HomeTheme.accentSoft
        }
    }
}

#Preview {
    QuickActionsChipsView(actions: ["Review Flashcards", "Continue Summary", "Take a Quiz", "AI Insights"], onSelect: { _ in })
        .padding()
        .background(HomeTheme.background)
}
