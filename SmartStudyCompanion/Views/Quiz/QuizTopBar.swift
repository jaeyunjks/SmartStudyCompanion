import SwiftUI

struct QuizTopBar: View {
    @Environment(\.quizPalette) private var palette

    let onClose: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack {
            roundButton(icon: "xmark", action: onClose)

            Spacer()

            Text("Knowledge Quiz")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

            roundButton(icon: "slider.horizontal.3", action: onOpenSettings)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(palette.surface.opacity(0.95))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
        .shadow(color: palette.shadow, radius: 10, x: 0, y: 5)
        .padding(.horizontal, 12)
    }

    private func roundButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 40, height: 40)
                .background(palette.accentSubtle)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuizTopBar(onClose: {}, onOpenSettings: {})
        .padding()
}