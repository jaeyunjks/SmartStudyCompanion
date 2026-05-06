import SwiftUI

struct QuizPalette {
    let base: Color
    let colorScheme: ColorScheme

    var background: Color {
        colorScheme == .dark ? Color(uiColor: .systemGroupedBackground) : Color(uiColor: .systemGroupedBackground)
    }

    var surface: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : Color(uiColor: .secondarySystemGroupedBackground)
    }

    var surfaceStrong: Color {
        colorScheme == .dark ? Color(uiColor: .tertiarySystemGroupedBackground) : Color(uiColor: .tertiarySystemGroupedBackground)
    }

    var accent: Color {
        colorScheme == .dark ? base.adjusted(saturation: 0.82, brightness: 0.90) : base.adjusted(saturation: 0.95, brightness: 0.78)
    }

    var accentSoft: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.60, brightness: 0.36, alpha: 0.42)
            : base.adjusted(saturation: 0.46, brightness: 1.10, alpha: 0.22)
    }

    var accentSubtle: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.56, brightness: 0.30, alpha: 0.24)
            : base.adjusted(saturation: 0.44, brightness: 1.12, alpha: 0.12)
    }

    var shadow: Color {
        Color.black.opacity(colorScheme == .dark ? 0.20 : 0.08)
    }

    var border: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    var error: Color {
        colorScheme == .dark ? Color.red.opacity(0.85) : Color(red: 0.74, green: 0.29, blue: 0.27)
    }

    static func fallback(for colorScheme: ColorScheme) -> QuizPalette {
        QuizPalette(base: WorkspaceTheme.accent, colorScheme: colorScheme)
    }
}

private struct QuizPaletteKey: EnvironmentKey {
    static var defaultValue: QuizPalette = .fallback(for: .light)
}

extension EnvironmentValues {
    var quizPalette: QuizPalette {
        get { self[QuizPaletteKey.self] }
        set { self[QuizPaletteKey.self] = newValue }
    }
}
