import SwiftUI

struct LibraryHeroHeaderView: View {
    private var titleText: AttributedString {
        var text = AttributedString("Your Knowledge Pavilion")
        if let range = text.range(of: "Pavilion") {
            text[range].foregroundColor = LibraryTheme.accent
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Knowledge Space")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(LibraryTheme.accent)
                .textCase(.uppercase)

            Text(titleText)
                .font(.system(size: 32, weight: .bold))

            Text("Manage your AI-powered study spaces and documents in one place.")
                .font(.subheadline)
                .foregroundStyle(LibraryTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(LibraryTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LibraryTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LibraryTheme.cardCornerRadius, style: .continuous)
                .stroke(LibraryTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    LibraryHeroHeaderView()
        .padding()
        .background(LibraryTheme.background)
}
