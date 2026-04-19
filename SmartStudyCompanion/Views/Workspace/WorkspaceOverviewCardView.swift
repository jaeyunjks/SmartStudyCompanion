import SwiftUI

struct WorkspaceOverviewCardView: View {
    @Environment(\.workspaceThemePalette) private var palette
    let studySpace: StudySpace
    let materialCount: Int
    let noteCount: Int
    let aiOutputCount: Int

    private var statusAccent: Color {
        studySpace.status == "Inactive" ? Color.gray : palette.primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(palette.iconBackground)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: studySpace.iconName)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(palette.primary)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(studySpace.title)
                        .font(.title3.weight(.bold))
                        .lineLimit(1)
                    Text(studySpace.lastOpened)
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
        .padding(18)
        .workspaceSurface(prominence: .primary)
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
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    WorkspaceOverviewCardView(studySpace: StudySpace.sampleData[0], materialCount: 4, noteCount: 2, aiOutputCount: 3)
        .padding()
}
