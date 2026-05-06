import SwiftUI

struct WorkspaceHeaderView: View {
    let studySpace: StudySpace
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: studySpace.iconName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(accent)
                    )

                Text(studySpace.normalizedStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(studySpace.statusForegroundColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(studySpace.statusBackgroundColor)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(studySpace.title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text(studySpace.description)
                    .font(.subheadline)
                    .foregroundStyle(WorkspaceTheme.mutedText)
                    .lineLimit(3)
            }

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.mutedText)
                Text(studySpace.lastUpdated)
                    .font(.footnote)
                    .foregroundStyle(WorkspaceTheme.mutedText)
            }
        }
        .padding(20)
        .background(WorkspaceTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                .stroke(accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    WorkspaceHeaderView(studySpace: StudySpace.sampleData[0], accent: WorkspaceTheme.accent)
        .padding()
}
