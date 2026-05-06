import SwiftUI

struct LibraryGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        colorScheme == .dark
                            ? Color(.secondarySystemBackground).opacity(0.82)
                            : Color(.systemBackground).opacity(0.64)
                    )
            )
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.10)
                            : LibraryTheme.glassBorder,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.22) : LibraryTheme.glassShadow,
                radius: 10,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func libraryGlass(cornerRadius: CGFloat = LibraryTheme.cardCornerRadius) -> some View {
        modifier(LibraryGlassModifier(cornerRadius: cornerRadius))
    }
}
