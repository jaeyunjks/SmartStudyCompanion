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
        HStack(spacing: 24) {
            ForEach(LibraryNavItem.allCases) { item in
                Button(action: { onSelect(item) }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                        Text(item.rawValue)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(selected == item ? LibraryTheme.accent : LibraryTheme.accent.opacity(0.4))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(selected == item ? LibraryTheme.accentSoft : Color.clear)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, LibraryTheme.horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(LibraryTheme.accent.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    LibraryBottomNavBarView(selected: .library, onSelect: { _ in })
}
