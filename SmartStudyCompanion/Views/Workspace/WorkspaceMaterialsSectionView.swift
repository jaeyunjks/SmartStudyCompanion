import SwiftUI

struct WorkspaceMaterialsSectionView: View {
    let materials: [StudyMaterial]
    let onTapMaterial: (StudyMaterial) -> Void
    let onToggleAISelection: (StudyMaterial) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Workspace Materials")
                    .font(.title2.weight(.bold))

                Spacer()

                Text("\(materials.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WorkspaceTheme.accentSoft)
                    .clipShape(Capsule())
            }

            if materials.isEmpty {
                Text("No materials yet. Tap + to import from Photos or Files.")
                    .font(.subheadline)
                    .foregroundStyle(WorkspaceTheme.mutedText)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
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
