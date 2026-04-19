import SwiftUI

struct StudySpaceColorOption: Identifiable {
    let id: String
    let name: String
    let color: Color
    var isCustom: Bool = false
}

struct StudySpaceColorPickerView: View {
    let colors: [StudySpaceColorOption]
    @Binding var selectedColorID: String
    let onAddCustomColor: () -> Void
    let onLongPressColor: (StudySpaceColorOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace Color")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors) { option in
                        let isSelected = selectedColorID == option.id
                        Button(action: { selectedColorID = option.id }) {
                            Circle()
                                .fill(option.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(option.color.opacity(isSelected ? 0.9 : 0.4), lineWidth: 2)
                                )
                                .shadow(color: option.color.opacity(0.25), radius: isSelected ? 6 : 0, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .onLongPressGesture {
                            guard option.isCustom else { return }
                            onLongPressColor(option)
                        }
                    }

                    Button(action: onAddCustomColor) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(CreateStudySpaceTheme.mutedText)
                            .frame(width: 30, height: 30)
                            .background(CreateStudySpaceTheme.secondaryBackground)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(CreateStudySpaceTheme.mutedText.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3]))
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
    StudySpaceColorPickerView(
        colors: [
            .init(id: "green", name: "Green", color: CreateStudySpaceTheme.accent),
            .init(id: "blue", name: "Blue", color: .blue)
        ],
        selectedColorID: .constant("green"),
        onAddCustomColor: {},
        onLongPressColor: { _ in }
    )
    .padding()
}
