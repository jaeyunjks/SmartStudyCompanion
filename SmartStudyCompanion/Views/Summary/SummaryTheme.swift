import SwiftUI

struct SummaryPalette {
    let base: Color
    let colorScheme: ColorScheme

    var background: Color {
        colorScheme == .dark ? Color(uiColor: .systemGroupedBackground) : Color(uiColor: .systemGroupedBackground)
    }

    var surface: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : Color(uiColor: .secondarySystemGroupedBackground)
    }

    var secondarySurface: Color {
        colorScheme == .dark ? Color(uiColor: .tertiarySystemGroupedBackground) : Color(uiColor: .tertiarySystemGroupedBackground)
    }

    var accent: Color {
        colorScheme == .dark ? base.adjusted(saturation: 0.82, brightness: 0.92) : base.adjusted(saturation: 0.90, brightness: 0.84)
    }

    var accentStrong: Color {
        colorScheme == .dark ? base.adjusted(saturation: 0.75, brightness: 0.78) : base.adjusted(saturation: 0.95, brightness: 0.70)
    }

    var accentSoft: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.50, brightness: 0.34, alpha: 0.45)
            : base.adjusted(saturation: 0.42, brightness: 1.12, alpha: 0.28)
    }

    var textSecondary: Color {
        Color(uiColor: .secondaryLabel)
    }

    var cardShadow: Color {
        Color.black.opacity(colorScheme == .dark ? 0.18 : 0.08)
    }

    static func fallback(for colorScheme: ColorScheme) -> SummaryPalette {
        SummaryPalette(base: WorkspaceTheme.accent, colorScheme: colorScheme)
    }
}

enum SummaryTheme {
    static let cornerLarge: CGFloat = 24
    static let cornerMedium: CGFloat = 18
}

private struct SummaryPaletteKey: EnvironmentKey {
    static var defaultValue: SummaryPalette = .fallback(for: .light)
}

extension EnvironmentValues {
    var summaryPalette: SummaryPalette {
        get { self[SummaryPaletteKey.self] }
        set { self[SummaryPaletteKey.self] = newValue }
    }
}

struct SummaryGlassBackground: ViewModifier {
    @Environment(\.summaryPalette) private var palette

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(palette.surface.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SummaryTheme.cornerLarge, style: .continuous)
                    .stroke(palette.accent.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: palette.cardShadow, radius: 14, x: 0, y: 8)
    }
}

extension View {
    func summaryGlassCard() -> some View {
        modifier(SummaryGlassBackground())
    }
}
