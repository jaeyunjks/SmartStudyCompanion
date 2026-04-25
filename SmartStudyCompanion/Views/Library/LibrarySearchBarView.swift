import SwiftUI

struct LibrarySearchBarView: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LibraryTheme.accent.opacity(0.65))

            TextField("Search study spaces, notes, or documents", text: $query)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)

            if !query.isEmpty {
                Button(action: { query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(LibraryTheme.mutedText.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .libraryGlass(cornerRadius: LibraryTheme.chipCornerRadius)
    }
}

#Preview {
    LibrarySearchBarView(query: .constant(""))
        .padding()
        .background(LibraryTheme.background)
}
