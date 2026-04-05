import SwiftUI

struct LibraryFloatingAddButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(LibraryTheme.accent)
                .clipShape(Circle())
                .shadow(color: LibraryTheme.accent.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add new study space")
    }
}

#Preview {
    LibraryFloatingAddButtonView(onTap: {})
        .padding()
        .background(LibraryTheme.background)
}
