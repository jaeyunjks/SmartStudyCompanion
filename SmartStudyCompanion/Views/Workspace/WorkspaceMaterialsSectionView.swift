import SwiftUI

struct WorkspaceMaterialsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette

    let materials: [StudyMaterial]
    let onTapMaterial: (StudyMaterial) -> Void
    let onToggleAISelection: (StudyMaterial) -> Void
    let onRenameMaterial: (StudyMaterial, String) -> Void
    let onDeleteMaterial: (StudyMaterial) -> Void
    let onViewAllMaterials: () -> Void

    @State private var renameMaterial: StudyMaterial?
    @State private var renameDraft = ""

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
                    ForEach(materials.prefix(3)) { material in
                        WorkspaceMaterialCardView(
                            material: material,
                            onTap: { onTapMaterial(material) },
                            onToggleAISelection: { onToggleAISelection(material) },
                            onRename: {
                                renameMaterial = material
                                renameDraft = material.title
                            },
                            onDelete: { onDeleteMaterial(material) }
                        )
                    }

                    if materials.count > 3 {
                        Button("View all") {
                            onViewAllMaterials()
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .workspaceSurface(prominence: .secondary)
        .alert("Rename Material", isPresented: Binding(
            get: { renameMaterial != nil },
            set: { newValue in if !newValue { renameMaterial = nil } }
        )) {
            TextField("Material name", text: $renameDraft)
            Button("Save") {
                if let material = renameMaterial {
                    onRenameMaterial(material, renameDraft)
                }
                renameMaterial = nil
            }
            Button("Cancel", role: .cancel) {
                renameMaterial = nil
            }
        } message: {
            Text("Rename \(renameMaterial?.title ?? "material")")
        }
        .onChange(of: renameMaterial) { _, newValue in
            if let newValue {
                renameDraft = newValue.title
            }
        }
    }
}

#Preview {
    WorkspaceMaterialsSectionView(
        materials: [],
        onTapMaterial: { _ in },
        onToggleAISelection: { _ in },
        onRenameMaterial: { _, _ in },
        onDeleteMaterial: { _ in },
        onViewAllMaterials: {}
    )
    .padding()
}
