import SwiftUI

struct LibraryGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.56))
            )
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(LibraryTheme.glassBorder, lineWidth: 1)
            )
            .shadow(color: LibraryTheme.glassShadow, radius: 10, x: 0, y: 6)
    }
}

extension View {
    func libraryGlass(cornerRadius: CGFloat = LibraryTheme.cardCornerRadius) -> some View {
        modifier(LibraryGlassModifier(cornerRadius: cornerRadius))
    }
}
