import SwiftUI

struct StudySpaceStatusPickerView: View {
    @Binding var selectedStatus: String
    let selectedColor: Color

    private let options = ["Active", "Inactive"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace Status")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selectedStatus == option
                    Button {
                        selectedStatus = option
                    } label: {
                        Text(option)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(isSelected ? .white : CreateStudySpaceTheme.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? selectedColor : CreateStudySpaceTheme.accentSoft.opacity(0.9))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    StudySpaceStatusPickerView(selectedStatus: .constant("Active"), selectedColor: CreateStudySpaceTheme.accent)
        .padding()
}
