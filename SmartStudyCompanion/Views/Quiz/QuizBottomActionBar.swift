import SwiftUI

struct QuizBottomActionBar: View {
    @Environment(\.quizPalette) private var palette

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
            .background(palette.accent)
            .clipShape(Capsule())
            .shadow(color: palette.accent.opacity(0.22), radius: 12, x: 0, y: 6)
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