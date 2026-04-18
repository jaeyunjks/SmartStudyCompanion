import SwiftUI

struct HomeGlassModifier: ViewModifier {
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
                    .stroke(HomeTheme.glassBorder, lineWidth: 1)
            )
            .shadow(color: HomeTheme.glassShadow, radius: 10, x: 0, y: 6)
    }
}

extension View {
    func homeGlass(cornerRadius: CGFloat = HomeTheme.cardCornerRadius) -> some View {
        modifier(HomeGlassModifier(cornerRadius: cornerRadius))
    }
}
