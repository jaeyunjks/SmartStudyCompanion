import SwiftUI
import UIKit

struct WorkspaceMaterialCardView: View {
    let material: StudyMaterial
    let onTap: () -> Void
    let onToggleAISelection: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                thumbnail

                Text(material.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(material.type.displayName)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(WorkspaceTheme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(WorkspaceTheme.accentSoft.opacity(0.85))
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: onToggleAISelection) {
                        Image(systemName: material.isSelectedForAIContext ? "sparkles" : "sparkles.slash")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(WorkspaceTheme.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WorkspaceTheme.accent.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WorkspaceTheme.accentSoft.opacity(0.4))
                .frame(height: 80)

            if material.type == .image, let image = UIImage(contentsOfFile: material.storedPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: material.type.systemIconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.accent)
            }
        }
    }
}

#Preview {
    WorkspaceMaterialCardView(
        material: StudyMaterial(
            workspaceID: UUID(),
            title: "Cloud Notes",
            type: .pdf,
            storedPath: "/tmp/demo.pdf",
            createdAt: Date()
        ),
        onTap: {},
        onToggleAISelection: {}
    )
    .padding()
}
