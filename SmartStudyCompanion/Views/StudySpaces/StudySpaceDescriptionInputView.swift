import SwiftUI

struct StudySpaceDescriptionInputView: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workspace Description (Optional)")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(CreateStudySpaceTheme.mutedText)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("What is the goal for this workspace?")
                        .font(.footnote)
                        .foregroundStyle(CreateStudySpaceTheme.mutedText.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $text)
                    .frame(height: 110)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
            }
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
    StudySpaceDescriptionInputView(text: .constant(""))
        .padding()
}
