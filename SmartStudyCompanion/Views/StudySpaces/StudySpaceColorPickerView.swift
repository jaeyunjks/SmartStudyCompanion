import SwiftUI

struct StudySpaceColorOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct StudySpaceColorPickerView: View {
    let colors: [StudySpaceColorOption]
    @Binding var selectedColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color")
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            HStack(spacing: 12) {
                ForEach(colors) { option in
                    Button(action: { selectedColor = option.color }) {
                        Circle()
                            .fill(option.color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == option.color ? 2 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(option.color.opacity(selectedColor == option.color ? 0.9 : 0.4), lineWidth: 2)
                            )
                            .shadow(color: option.color.opacity(0.25), radius: selectedColor == option.color ? 6 : 0, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    StudySpaceColorPickerView(
        colors: [
            .init(name: "Green", color: CreateStudySpaceTheme.accent),
            .init(name: "Blue", color: .blue)
        ],
        selectedColor: .constant(CreateStudySpaceTheme.accent)
    )
    .padding()
}
