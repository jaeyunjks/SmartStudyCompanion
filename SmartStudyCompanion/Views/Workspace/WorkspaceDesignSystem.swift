import SwiftUI

struct WorkspaceThemePalette {
    let base: Color
    let colorScheme: ColorScheme

    var primary: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.86, brightness: 0.90)
            : base
    }

    var primaryStrong: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.80, brightness: 0.72)
            : base.adjusted(saturation: 1.05, brightness: 0.78)
    }

    var primarySoft: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.55, brightness: 0.42, alpha: 0.30)
            : base.adjusted(saturation: 0.55, brightness: 1.10, alpha: 0.22)
    }

    var tintedBackground: Color {
        colorScheme == .dark ? Color(red: 0.11, green: 0.15, blue: 0.14) : Color(red: 0.95, green: 0.97, blue: 0.96)
    }

    var iconBackground: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.55, brightness: 0.38, alpha: 0.45)
            : base.adjusted(saturation: 0.50, brightness: 1.10, alpha: 0.20)
    }

    var chipBackground: Color {
        colorScheme == .dark
            ? base.adjusted(saturation: 0.70, brightness: 0.35, alpha: 0.42)
            : base.adjusted(saturation: 0.45, brightness: 1.12, alpha: 0.22)
    }

    var selectedBackground: Color {
        colorScheme == .dark ? primaryStrong : primary
    }

    var textOnPrimary: Color {
        .white
    }

    static func fallback(for colorScheme: ColorScheme) -> WorkspaceThemePalette {
        WorkspaceThemePalette(base: WorkspaceTheme.accent, colorScheme: colorScheme)
    }
}

private struct WorkspaceThemePaletteKey: EnvironmentKey {
    static var defaultValue: WorkspaceThemePalette = .fallback(for: .light)
}

extension EnvironmentValues {
    var workspaceThemePalette: WorkspaceThemePalette {
        get { self[WorkspaceThemePaletteKey.self] }
        set { self[WorkspaceThemePaletteKey.self] = newValue }
    }
}

struct WorkspacePressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

enum WorkspaceSurfaceProminence {
    case primary
    case secondary
    case tertiary
}

struct WorkspaceSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let prominence: WorkspaceSurfaceProminence
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
    }

    private var background: some ShapeStyle {
        switch prominence {
        case .primary:
            return AnyShapeStyle(WorkspaceTheme.surfaceSecondary(for: colorScheme))
        case .secondary:
            return AnyShapeStyle(WorkspaceTheme.surfaceSecondary(for: colorScheme))
        case .tertiary:
            return AnyShapeStyle(WorkspaceTheme.surfaceTertiary(for: colorScheme))
        }
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    private var shadowColor: Color {
        Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08)
    }

    private var shadowRadius: CGFloat {
        switch prominence {
        case .primary: return 14
        case .secondary: return 10
        case .tertiary: return 6
        }
    }

    private var shadowYOffset: CGFloat {
        switch prominence {
        case .primary: return 8
        case .secondary: return 5
        case .tertiary: return 3
        }
    }
}

extension View {
    func workspaceSurface(prominence: WorkspaceSurfaceProminence = .primary, cornerRadius: CGFloat = WorkspaceTheme.cornerRadius) -> some View {
        modifier(WorkspaceSurfaceModifier(prominence: prominence, cornerRadius: cornerRadius))
    }
}
