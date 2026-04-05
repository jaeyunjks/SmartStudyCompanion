import SwiftUI

struct LibraryTopBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                Text("Library")
                    .font(.system(size: 20, weight: .heavy))
                    .italic()
            }
            .foregroundStyle(LibraryTheme.accent)

            Spacer()

            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LibraryTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(LibraryTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, LibraryTheme.horizontalPadding)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(LibraryTheme.accent.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    LibraryTopBarView()
}
