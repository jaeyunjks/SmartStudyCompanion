import SwiftUI

struct StudySpaceCategoryPickerView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    let selectedColor: Color
    let onAddCategory: () -> Void
    let isCustomCategory: (String) -> Bool
    let onLongPressCategory: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace Category")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(selectedCategory == category ? Color.white : CreateStudySpaceTheme.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? selectedColor : CreateStudySpaceTheme.accentSoft)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .onLongPressGesture {
                            guard isCustomCategory(category) else { return }
                            onLongPressCategory(category)
                        }
                    }

                    Button(action: onAddCategory) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(CreateStudySpaceTheme.mutedText)
                            .frame(width: 32, height: 32)
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
    StudySpaceCategoryPickerView(
        categories: ["IT", "AI", "Math", "Design"],
        selectedCategory: .constant("IT"),
        selectedColor: CreateStudySpaceTheme.accent,
        onAddCategory: {},
        isCustomCategory: { _ in false },
        onLongPressCategory: { _ in }
    )
    .padding()
}
