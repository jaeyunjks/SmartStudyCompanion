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
                .overlay(
                    Circle().stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: LibraryTheme.accent.opacity(0.24), radius: 11, x: 0, y: 7)
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
