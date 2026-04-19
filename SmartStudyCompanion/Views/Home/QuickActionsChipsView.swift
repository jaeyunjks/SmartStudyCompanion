import SwiftUI

struct QuickActionsChipsView: View {
    let actions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(HomeTheme.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                ForEach(actions, id: \.self) { action in
                    Button(action: { onSelect(action) }) {
                        HStack(spacing: 8) {
                            Image(systemName: iconName(for: action))
                                .font(.system(size: 13, weight: .semibold))
                            Text(action)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(HomeTheme.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(tint(for: action))
                        .overlay(
                            Capsule()
                                .stroke(HomeTheme.accent.opacity(0.08), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                }
                .padding(.vertical, 2)
            }
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
