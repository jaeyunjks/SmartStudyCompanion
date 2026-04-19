import SwiftUI
import UIKit

struct WorkspaceMaterialCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let material: StudyMaterial
    let onTap: () -> Void
    let onToggleAISelection: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                thumbnail

                VStack(alignment: .leading, spacing: 6) {
                    Text(material.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(material.type.displayName)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(palette.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(palette.chipBackground.opacity(0.9))
                            .clipShape(Capsule())

                        Text(material.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(WorkspaceTheme.mutedText)
                    }
                }

                Spacer()

                Button(action: onToggleAISelection) {
                    Image(systemName: material.isSelectedForAIContext ? "sparkles" : "sparkles.slash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.primary)
                        .frame(width: 30, height: 30)
                        .background(palette.iconBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(WorkspaceTheme.surfaceTertiary(for: colorScheme).opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(palette.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(WorkspacePressableButtonStyle())
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.iconBackground.opacity(0.7))
                .frame(width: 56, height: 56)

            if material.type == .image, let image = UIImage(contentsOfFile: material.storedPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: material.type.systemIconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(palette.primary)
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
