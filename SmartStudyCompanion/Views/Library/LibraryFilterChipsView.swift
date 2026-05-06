import SwiftUI

struct LibraryFilterChipsView: View {
    @Binding var selectedSort: String
    let hasActiveAdvancedFilters: Bool
    let onFilterTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChipView(
                        title: "Recently Updated",
                        isSelected: selectedSort == "Recently Updated"
                    )
                    .onTapGesture { selectedSort = "Recently Updated" }

                    FilterChipView(
                        title: "Alphabetical",
                        isSelected: selectedSort == "Alphabetical"
                    )
                    .onTapGesture { selectedSort = "Alphabetical" }
                }
                .padding(.vertical, 2)
            }

            Button(action: onFilterTap) {
                Image(systemName: hasActiveAdvancedFilters ? "slider.horizontal.3.circle.fill" : "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LibraryTheme.accent)
                    .frame(width: 40, height: 40)
                    .libraryGlass(cornerRadius: 20)
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
            .foregroundStyle(isSelected ? Color.white : LibraryTheme.accent.opacity(0.9))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? LibraryTheme.accent : Color.white.opacity(0.72))
            .overlay(
                Capsule()
                    .stroke(LibraryTheme.accent.opacity(isSelected ? 0.0 : 0.18), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

#Preview {
    LibraryFilterChipsView(
        selectedSort: .constant("Recently Updated"),
        hasActiveAdvancedFilters: true,
        onFilterTap: {}
    )
    .padding()
    .background(LibraryTheme.background)
}
