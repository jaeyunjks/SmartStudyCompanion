import SwiftUI

struct QuickActionsChipsView: View {
    private let actions: [QuickAction] = [
        .init(title: "Review Flashcards", icon: "bolt.fill", tint: Color(red: 0.86, green: 0.94, blue: 0.89)),
        .init(title: "Continue Summary", icon: "doc.text", tint: Color(red: 0.88, green: 0.94, blue: 0.85)),
        .init(title: "Take a Quiz", icon: "questionmark.circle", tint: Color(red: 0.86, green: 0.93, blue: 0.95)),
        .init(title: "AI Insights", icon: "sparkles", tint: Color(red: 0.94, green: 0.96, blue: 0.93))
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(actions) { action in
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.system(size: 14, weight: .semibold))
                            Text(action.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(action.tint)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let tint: Color
}

#Preview {
    QuickActionsChipsView()
        .padding()
        .background(HomeTheme.background)
}
