import SwiftUI

struct CreateStudySpaceHeaderView: View {
    let title: String
    let subtitle: String
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CreateStudySpaceTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(CreateStudySpaceTheme.mutedText)
                    .frame(width: 36, height: 36)
                    .background(CreateStudySpaceTheme.secondaryBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(CreateStudySpaceTheme.accent.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    CreateStudySpaceHeaderView(
        title: "Create Study Space",
        subtitle: "Design your digital sanctuary for focused learning.",
        onClose: {}
    )
    .padding()
}
