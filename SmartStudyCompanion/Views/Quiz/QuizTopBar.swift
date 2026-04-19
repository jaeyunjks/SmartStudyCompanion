import SwiftUI

struct QuizTopBar: View {
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QuizTheme.accent)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.62))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Knowledge Quiz")
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(QuizTheme.accent)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(QuizTheme.accentSoft.opacity(0.44))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: QuizTheme.shadow, radius: 14, x: 0, y: 8)
        .padding(.horizontal, 12)
    }
}

#Preview {
    QuizTopBar(onClose: {})
        .padding()
        .background(QuizTheme.background)
}
