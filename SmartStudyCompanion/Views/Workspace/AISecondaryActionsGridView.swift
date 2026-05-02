import SwiftUI

struct AISecondaryActionsGridView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette

    let actions: [AISecondaryAction]
    let onSelect: (AISecondaryAction) -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(actions) { action in
                Button(action: { onSelect(action) }) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Circle()
                                .fill(palette.iconBackground)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: action.iconName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(palette.primary)
                                )

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }

                        Text(action.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(action.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.14 : 0.04), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(WorkspacePressableButtonStyle())
            }
        }
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(uiColor: .secondarySystemBackground)
            : Color(red: 0.975, green: 0.982, blue: 0.978)
    }
}

#Preview {
    AISecondaryActionsGridView(actions: [
        .init(title: "Ask AI", subtitle: "Get help from Lumora", iconName: "message"),
        .init(title: "Quiz", subtitle: "Practice key concepts", iconName: "questionmark.circle")
    ], onSelect: { _ in })
    .padding()
}
