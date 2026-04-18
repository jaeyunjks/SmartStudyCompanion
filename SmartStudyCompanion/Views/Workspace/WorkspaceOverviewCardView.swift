import SwiftUI

struct WorkspaceOverviewCardView: View {
    let studySpace: StudySpace

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(WorkspaceTheme.accentSoft.opacity(0.95))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: studySpace.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(WorkspaceTheme.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(studySpace.title)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                    Text(studySpace.lastUpdated)
                        .font(.caption)
                        .foregroundStyle(WorkspaceTheme.mutedText)
                }

                Spacer(minLength: 8)

                Text(studySpace.status)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(WorkspaceTheme.accentSoft.opacity(0.95))
                    .clipShape(Capsule())
            }

            Text(studySpace.description)
                .font(.subheadline)
                .foregroundStyle(WorkspaceTheme.mutedText)
                .lineLimit(2)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Workspace Progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WorkspaceTheme.accent)
                    Spacer()
                    Text("\(Int(studySpace.progress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(WorkspaceTheme.accent)
                }

                ProgressView(value: studySpace.progress)
                    .tint(WorkspaceTheme.accent)
                    .background(WorkspaceTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(WorkspaceTheme.secondaryBackground.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                .stroke(WorkspaceTheme.accent.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: WorkspaceTheme.accent.opacity(0.06), radius: 14, x: 0, y: 8)
    }
}

#Preview {
    WorkspaceOverviewCardView(studySpace: StudySpace.sampleData[0])
        .padding()
}
