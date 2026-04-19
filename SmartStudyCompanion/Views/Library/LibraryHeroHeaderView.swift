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
        VStack(alignment: .leading, spacing: 10) {
            Text("Knowledge Space")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LibraryTheme.accent)
                .textCase(.uppercase)
                .tracking(1.1)

            Text(titleText)
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("Search, filter, and manage all study spaces and materials in one calm workspace.")
                .font(.subheadline)
                .foregroundStyle(LibraryTheme.mutedText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .libraryGlass(cornerRadius: LibraryTheme.cardCornerRadius)
    }
}

#Preview {
    LibraryHeroHeaderView()
        .padding()
        .background(LibraryTheme.background)
}
