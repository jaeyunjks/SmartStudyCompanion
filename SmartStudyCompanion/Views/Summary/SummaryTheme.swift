import SwiftUI

enum SummaryTheme {
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let surface = Color.white.opacity(0.76)
    static let secondarySurface = Color(red: 0.95, green: 0.97, blue: 0.95)
    static let accent = Color(red: 0.24, green: 0.42, blue: 0.33)
    static let accentStrong = Color(red: 0.20, green: 0.36, blue: 0.28)
    static let accentSoft = Color(red: 0.84, green: 0.92, blue: 0.86)
    static let textSecondary = Color(red: 0.34, green: 0.38, blue: 0.37)

    static let cornerLarge: CGFloat = 24
    static let cornerMedium: CGFloat = 18

    static let cardShadow = Color(red: 0.20, green: 0.36, blue: 0.28).opacity(0.08)
}

struct SummaryGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(SummaryTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous)
                    .stroke(SummaryTheme.accent.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: SummaryTheme.cardShadow, radius: 18, x: 0, y: 10)
    }
}

extension View {
    func summaryGlassCard() -> some View {
        modifier(SummaryGlassBackground())
    }
}
