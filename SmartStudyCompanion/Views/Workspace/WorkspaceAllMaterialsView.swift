import SwiftUI

struct WorkspaceAllMaterialsView: View {
    enum MaterialFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case photos = "Photos"
        case files = "Files"

        var id: String { rawValue }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let materials: [StudyMaterial]
    let onOpen: (StudyMaterial) -> Void
    let onToggleAISelection: (StudyMaterial) -> Void
    let onRename: (StudyMaterial, String) -> Void
    let onDelete: (StudyMaterial) -> Void

    @State private var searchText = ""
    @State private var filter: MaterialFilter = .all
    @State private var renameMaterial: StudyMaterial?
    @State private var renameDraft = ""

    private var filteredMaterials: [StudyMaterial] {
        let byType: [StudyMaterial]
        switch filter {
        case .all:
            byType = materials
        case .photos:
            byType = materials.filter { $0.type == .image }
        case .files:
            byType = materials.filter { $0.type != .image }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return byType }
        return byType.filter { material in
            material.title.localizedCaseInsensitiveContains(query)
                || material.type.displayName.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Type", selection: $filter) {
                    ForEach(MaterialFilter.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if filteredMaterials.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("No materials found")
                            .font(.headline)
                        Text("Try changing filter or search.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredMaterials) { material in
                                MaterialRowCard(
                                    material: material,
                                    colorScheme: colorScheme,
                                    onOpen: { onOpen(material) },
                                    onToggleAISelection: { onToggleAISelection(material) },
                                    onRename: {
                                        renameMaterial = material
                                        renameDraft = material.title
                                    },
                                    onDelete: { onDelete(material) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("All Materials")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search materials")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Rename Material", isPresented: Binding(
            get: { renameMaterial != nil },
            set: { newValue in if !newValue { renameMaterial = nil } }
        )) {
            TextField("Material name", text: $renameDraft)
            Button("Save") {
                if let material = renameMaterial {
                    onRename(material, renameDraft)
                }
                renameMaterial = nil
            }
            Button("Cancel", role: .cancel) {
                renameMaterial = nil
            }
        }
    }
}

private struct MaterialRowCard: View {
    let material: StudyMaterial
    let colorScheme: ColorScheme
    let onOpen: () -> Void
    let onToggleAISelection: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 12) {
                thumbnail

                VStack(alignment: .leading, spacing: 6) {
                    Text(material.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(material.type.displayName)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Capsule())

                        Text(material.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 6)

                Button(action: onToggleAISelection) {
                    Image(systemName: material.isSelectedForAIContext ? "sparkles" : "sparkles.slash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Menu {
                    Button("Rename", action: onRename)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Rename", action: onRename)
                .tint(.blue)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .frame(width: 52, height: 52)

            if material.type == .image, let image = UIImage(contentsOfFile: material.storedPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Image(systemName: material.type.systemIconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WorkspaceAllMaterialsView(
        materials: [],
        onOpen: { _ in },
        onToggleAISelection: { _ in },
        onRename: { _, _ in },
        onDelete: { _ in }
    )
}
