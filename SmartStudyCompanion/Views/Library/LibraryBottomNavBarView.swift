import SwiftUI

enum LibraryNavItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case library = "Library"
    case profile = "Profile"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .library:
            return "books.vertical"
        case .profile:
            return "person.crop.circle"
        }
    }
}

struct LibraryBottomNavBarView: View {
    let selected: LibraryNavItem
    let onSelect: (LibraryNavItem) -> Void

    var body: some View {
        HStack(spacing: 18) {
            ForEach(LibraryNavItem.allCases) { item in
                Button(action: { onSelect(item) }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                        Text(item.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selected == item ? LibraryTheme.accent : LibraryTheme.accent.opacity(0.45))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(selected == item ? LibraryTheme.accentSoft.opacity(0.9) : Color.clear)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .center)
        .libraryGlass(cornerRadius: 24)
        .padding(.horizontal, LibraryTheme.horizontalPadding)
        .padding(.top, 2)
        .padding(.bottom, 2)
    }
}

#Preview {
    LibraryBottomNavBarView(selected: .library, onSelect: { _ in })
}
