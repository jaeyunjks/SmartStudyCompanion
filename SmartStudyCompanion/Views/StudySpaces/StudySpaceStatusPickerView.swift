import SwiftUI

struct StudySpaceStatusPickerView: View {
    @Binding var selectedStatus: StudySpaceStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace Status")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            HStack(spacing: 8) {
                ForEach(StudySpaceStatus.allCases) { option in
                    let isSelected = selectedStatus == option
                    Button {
                        selectedStatus = option
                    } label: {
                        Text(option.displayName)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(isSelected ? .white : option.foregroundColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? option.foregroundColor : option.backgroundColor)
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
    StudySpaceStatusPickerView(selectedStatus: .constant(.active))
        .padding()
}
