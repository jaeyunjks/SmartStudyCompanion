import SwiftUI

struct WorkspaceMaterialsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette
    let materials: [StudyMaterial]
    let onTapMaterial: (StudyMaterial) -> Void
    let onToggleAISelection: (StudyMaterial) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Workspace Materials")
                    .font(.title3.weight(.bold))

                Spacer()

                Text("\(materials.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(palette.chipBackground)
                    .clipShape(Capsule())
            }

            if materials.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No materials yet")
                        .font(.subheadline.weight(.semibold))
                    Text("Tap + to import from Photos or Files.")
                        .font(.footnote)
                        .foregroundStyle(WorkspaceTheme.mutedText)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WorkspaceTheme.surfaceSecondary(for: colorScheme).opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(materials) { material in
                        WorkspaceMaterialCardView(
                            material: material,
                            onTap: { onTapMaterial(material) },
                            onToggleAISelection: { onToggleAISelection(material) }
                        )
                    }
                }
            }
        }
        .padding(16)
        .workspaceSurface(prominence: .secondary)
    }
}

#Preview {
    WorkspaceMaterialsSectionView(
        materials: [],
        onTapMaterial: { _ in },
        onToggleAISelection: { _ in }
    )
    .padding()
}
