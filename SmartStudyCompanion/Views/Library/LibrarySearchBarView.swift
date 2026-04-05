import SwiftUI

struct LibrarySearchBarView: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LibraryTheme.accent.opacity(0.7))

            TextField("Search study spaces, notes, or documents", text: $query)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(LibraryTheme.secondaryBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(LibraryTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    LibrarySearchBarView(query: .constant(""))
        .padding()
        .background(LibraryTheme.background)
}
