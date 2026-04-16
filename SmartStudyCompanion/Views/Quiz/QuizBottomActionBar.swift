import SwiftUI

struct QuizBottomActionBar: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Image(systemName: "arrow.forward")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(QuizTheme.accent)
            .clipShape(Capsule())
            .shadow(color: QuizTheme.accent.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

#Preview {
    QuizBottomActionBar(title: "Check Answer", isEnabled: true, action: {})
        .padding()
}
