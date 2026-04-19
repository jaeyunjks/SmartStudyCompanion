import SwiftUI

struct WorkspaceOverviewCardView: View {
    let studySpace: StudySpace
    let materialCount: Int
    let noteCount: Int
    let aiOutputCount: Int

    private var statusAccent: Color {
        studySpace.status == "Inactive" ? Color.gray : WorkspaceTheme.accent
    }

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
                    .foregroundStyle(statusAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusAccent.opacity(0.14))
                    .clipShape(Capsule())
            }

            Text(studySpace.description)
                .font(.subheadline)
                .foregroundStyle(WorkspaceTheme.mutedText)
                .lineLimit(2)

            HStack(spacing: 10) {
                metadataChip(title: "Materials", value: "\(materialCount)")
                metadataChip(title: "Notes", value: "\(noteCount)")
                metadataChip(title: "AI Outputs", value: "\(aiOutputCount)")
            }
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

    private func metadataChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(WorkspaceTheme.mutedText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(WorkspaceTheme.secondaryBackground.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    WorkspaceOverviewCardView(studySpace: StudySpace.sampleData[0], materialCount: 4, noteCount: 2, aiOutputCount: 3)
        .padding()
}
