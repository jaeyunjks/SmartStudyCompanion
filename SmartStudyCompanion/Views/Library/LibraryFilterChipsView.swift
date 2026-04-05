import SwiftUI

struct LibraryFilterChipsView: View {
    @Binding var selectedFilter: String
    let onFilterTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChipView(
                        title: "Recently Updated",
                        isSelected: selectedFilter == "Recently Updated"
                    )
                    .onTapGesture { selectedFilter = "Recently Updated" }

                    FilterChipView(
                        title: "Alphabetical",
                        isSelected: selectedFilter == "Alphabetical"
                    )
                    .onTapGesture { selectedFilter = "Alphabetical" }
                }
            }

            Button(action: onFilterTap) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LibraryTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(LibraryTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct FilterChipView: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(isSelected ? Color.white : LibraryTheme.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? LibraryTheme.accent : LibraryTheme.accentSoft)
            .clipShape(Capsule())
    }
}

#Preview {
    LibraryFilterChipsView(selectedFilter: .constant("Recently Updated"), onFilterTap: {})
        .padding()
        .background(LibraryTheme.background)
}
