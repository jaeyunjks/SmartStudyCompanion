import SwiftUI

struct StudySpaceStatusPickerView: View {
    @Binding var selectedStatus: String

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
                    let optionTint = option == "Inactive"
                        ? Color(red: 0.76, green: 0.25, blue: 0.30)
                        : Color(red: 0.22, green: 0.58, blue: 0.38)
                    Button {
                        selectedStatus = option
                    } label: {
                        Text(option)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(isSelected ? .white : optionTint)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? optionTint : optionTint.opacity(0.14))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StudySpaceStatusPickerView(selectedStatus: .constant("Active"))
        .padding()
}
