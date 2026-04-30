import SwiftUI

struct WorkspaceTintCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let accent: Color
    let cornerRadius: CGFloat

    private var topTintOpacity: Double {
        colorScheme == .dark ? 0.14 : 0.14
    }

    private var bottomTintOpacity: Double {
        colorScheme == .dark ? 0.11 : 0.10
    }

    private var shadowOpacity: Double {
        colorScheme == .dark ? 0.06 : 0.10
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(topTintOpacity),
                                accent.opacity(bottomTintOpacity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(accent.opacity(colorScheme == .dark ? 0.18 : 0.14), lineWidth: 1)
            )
            .shadow(color: accent.opacity(shadowOpacity), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func workspaceTintCard(accent: Color, cornerRadius: CGFloat) -> some View {
        modifier(WorkspaceTintCardModifier(accent: accent, cornerRadius: cornerRadius))
    }
}
