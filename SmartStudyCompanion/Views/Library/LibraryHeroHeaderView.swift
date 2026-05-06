import SwiftUI

struct LibraryHeroHeaderView: View {
    private var titleText: AttributedString {
        var text = AttributedString("Organise Your Study Library")
        if let range = text.range(of: "Library") {
            text[range].foregroundColor = LibraryTheme.accent
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Knowledge Space")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(LibraryTheme.accent)
                .textCase(.uppercase)
                .tracking(0.9)

            Text(titleText)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .lineLimit(2)

            Text("Search, filter, and manage all study spaces and materials in one calm workspace.")
                .font(.footnote)
                .foregroundStyle(LibraryTheme.mutedText)
                .lineSpacing(1.6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .libraryGlass(cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    LibraryHeroHeaderView()
        .padding()
        .background(LibraryTheme.background)
}
