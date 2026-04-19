import SwiftUI

struct StudySpaceNameInputView: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workspace Name")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            TextField("e.g., Cloud Computing Final Review", text: $text)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 18)
                .frame(height: 52)
                .background(CreateStudySpaceTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CreateStudySpaceTheme.fieldCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CreateStudySpaceTheme.fieldCornerRadius, style: .continuous)
                        .stroke(CreateStudySpaceTheme.accent.opacity(0.08), lineWidth: 1)
                )
        }
    }
}

#Preview {
    StudySpaceNameInputView(text: .constant(""))
        .padding()
}
