import SwiftUI

struct StudySpaceIconPickerView: View {
    let icons: [String]
    @Binding var selectedIconName: String
    let selectedColor: Color
    let onAdd: () -> Void
    let isCustomIcon: (String) -> Bool
    let onLongPressIcon: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace Icon")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: { selectedIconName = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(selectedIconName == icon ? .white : CreateStudySpaceTheme.mutedText)
                                .frame(width: 50, height: 50)
                                .background(selectedIconName == icon ? selectedColor : CreateStudySpaceTheme.secondaryBackground)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(selectedColor.opacity(selectedIconName == icon ? 0.35 : 0), lineWidth: 2)
                                )
                                .shadow(color: selectedColor.opacity(selectedIconName == icon ? 0.25 : 0), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .onLongPressGesture {
                            guard isCustomIcon(icon) else { return }
                            onLongPressIcon(icon)
                        }
                    }

                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(CreateStudySpaceTheme.mutedText)
                            .frame(width: 50, height: 50)
                            .background(CreateStudySpaceTheme.secondaryBackground)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(CreateStudySpaceTheme.mutedText.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

#Preview {
    StudySpaceIconPickerView(
        icons: ["cloud", "brain.head.profile", "book.closed"],
        selectedIconName: .constant("cloud"),
        selectedColor: CreateStudySpaceTheme.accent,
        onAdd: {},
        isCustomIcon: { _ in false },
        onLongPressIcon: { _ in }
    )
    .padding()
}
