import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import UIKit

enum WorkspaceTheme {
    static let accent = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.42, green: 0.64, blue: 0.53, alpha: 1)
            : UIColor(red: 0.22, green: 0.53, blue: 0.40, alpha: 1)
    })
    static let deepAccent = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.31, green: 0.51, blue: 0.42, alpha: 1)
            : UIColor(red: 0.16, green: 0.43, blue: 0.33, alpha: 1)
    })
    static let accentSoft = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.28, blue: 0.25, alpha: 1)
            : UIColor(red: 0.86, green: 0.94, blue: 0.89, alpha: 1)
    })
    static let mintTint = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.23, blue: 0.20, alpha: 1)
            : UIColor(red: 0.91, green: 0.97, blue: 0.94, alpha: 1)
    })
    static let background = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.systemGroupedBackground
            : UIColor.systemGroupedBackground
    })
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.secondarySystemBackground
            : UIColor.secondarySystemBackground
    })
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 20
    static let sectionSpacing: CGFloat = 22

    static func surfaceSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(uiColor: .secondarySystemGroupedBackground)
            : Color(uiColor: .secondarySystemGroupedBackground)
    }

    static func surfaceTertiary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(uiColor: .tertiarySystemGroupedBackground)
            : Color(uiColor: .tertiarySystemGroupedBackground)
    }
}

struct ActivityItem: Identifiable {
    let id: UUID
    let iconName: String
    let title: String
    let timestamp: String
    let detail: String
}

private struct WorkspaceSummaryRoute: Identifiable, Hashable {
    let id = UUID()
    let request: WorkspaceAISummaryRequest
    let workspaceColorHex: String
    let sourceItems: [SummarySourceItem]
}

private enum ComingSoonFeature: String, Identifiable {
    case quiz
    case flashcards
    case studyPlan

    var id: String { rawValue }
}

struct ActiveWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: ActiveWorkspaceViewModel

    @State private var showWorkspaceMenu = false
    @State private var showDeleteWorkspaceConfirmation = false
    @State private var showEditWorkspaceSheet = false
    @State private var activeNoteDraft: WorkspaceNote?
    @State private var summaryRoute: WorkspaceSummaryRoute?
    @State private var showAllNotes = false
    @State private var showAllMaterials = false
    @State private var showAIChat = false
    @State private var showKnowledgeQuiz = false
    @State private var showFlashcardSession = false
    @State private var showStudyPlan = false
    @State private var comingSoonFeature: ComingSoonFeature?
    @State private var showImportOptions = false
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    init(studySpace: StudySpace) {
        _viewModel = StateObject(wrappedValue: ActiveWorkspaceViewModel(studySpace: studySpace))
    }

    var body: some View {
        let workspacePalette = WorkspaceThemePalette(base: viewModel.workspace.workspaceAccentColor, colorScheme: colorScheme)

        GeometryReader { geometry in
            let topInset = geometry.safeAreaInsets.top
            let bottomInset = geometry.safeAreaInsets.bottom

            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [
                        WorkspaceTheme.background,
                        WorkspaceTheme.surfaceSecondary(for: colorScheme)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    WorkspaceTopBarView(
                        title: "Active Study Workspace",
                        onBack: { dismiss() },
                        onMore: { showWorkspaceMenu = true }
                    )
                    .padding(.top, topInset + 2)

                    ScrollView {
                        VStack(alignment: .leading, spacing: WorkspaceTheme.sectionSpacing) {
                            WorkspaceSectionLabel(title: "Workspace")
                            WorkspaceOverviewCardView(
                                studySpace: viewModel.workspace,
                                materialCount: viewModel.materialCount,
                                noteCount: viewModel.noteCount
                            )

                                WorkspaceStudyToolsSectionView(
                                    onCreateNote: { activeNoteDraft = viewModel.makeDraftNote() },
                                    onPrimaryAction: { handleAction("Summarise Knowledge") },
                                    onSecondaryAction: { handleAction($0) }
                                )

                            WorkspaceSectionLabel(title: "Notes")
                            WorkspaceNotesSectionView(
                                notes: viewModel.notes,
                                onCreateNote: { activeNoteDraft = viewModel.makeDraftNote() },
                                onSelectNote: { note in activeNoteDraft = note },
                                onViewAllNotes: { showAllNotes = true }
                            )

                            WorkspaceSectionLabel(title: "Materials")
                            WorkspaceMaterialsSectionView(
                                materials: viewModel.materials,
                                onTapMaterial: { material in
                                    viewModel.openPreview(for: material)
                                },
                                onToggleAISelection: { material in
                                    viewModel.toggleMaterialSelectionForAI(material.id)
                                },
                                onRenameMaterial: { material, newTitle in
                                    viewModel.renameMaterial(material, to: newTitle)
                                },
                                onDeleteMaterial: { material in
                                    viewModel.deleteMaterial(material)
                                },
                                onViewAllMaterials: {
                                    showAllMaterials = true
                                }
                            )

                            if !recentActivityItems.isEmpty {
                                WorkspaceSectionLabel(title: "Activity")
                                RecentActivitySectionView(items: recentActivityItems)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 110 + bottomInset)
                    }
                }

                WorkspaceFloatingAddButtonView {
                    showImportOptions = true
                }
                .padding(.trailing, 22)
                .padding(.bottom, max(bottomInset, 8) + 14)
            }
            .ignoresSafeArea(edges: [.top, .bottom])
            .environment(\.workspaceThemePalette, workspacePalette)
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItems,
            maxSelectionCount: 20,
            matching: .images,
            preferredItemEncoding: .automatic
        )
        .onChange(of: selectedPhotoItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await viewModel.importPhoto(data: data, fileName: nil)
                    } else {
                        viewModel.importErrorMessage = "Could not load one of the selected photos."
                    }
                }
                selectedPhotoItems = []
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: supportedDocumentTypes,
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                guard !urls.isEmpty else { return }
                Task {
                    for url in urls {
                        await viewModel.importDocument(from: url)
                    }
                }
            case .failure:
                viewModel.importErrorMessage = "File import was cancelled or failed."
            }
        }
        .confirmationDialog("Import Study Material", isPresented: $showImportOptions, titleVisibility: .visible) {
            Button("Photo Library") { showPhotoPicker = true }
            Button("Files") { showFileImporter = true }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Workspace Actions", isPresented: $showWorkspaceMenu, titleVisibility: .visible) {
            Button("Edit Workspace") {
                showEditWorkspaceSheet = true
            }
            Button("Set as Active") {
                viewModel.updateWorkspaceStatus(.active)
            }
            Button("Set as Inactive") {
                viewModel.updateWorkspaceStatus(.inactive)
            }
            Button("Delete Workspace", role: .destructive) {
                showDeleteWorkspaceConfirmation = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Workspace?", isPresented: $showDeleteWorkspaceConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteWorkspace()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This workspace and its local materials will no longer be listed.")
        }
        .sheet(isPresented: $showEditWorkspaceSheet) {
            CreateStudySpaceView(initialSpace: viewModel.workspace, onCreate: { title, icon, category, description, status, workspaceColorHex in
                viewModel.editWorkspace(
                    title: title,
                    iconName: icon,
                    category: category,
                    description: description,
                    status: status,
                    workspaceColorHex: workspaceColorHex
                )
                showEditWorkspaceSheet = false
            })
        }
        .sheet(item: $viewModel.selectedMaterialForPreview) { material in
            WorkspaceMaterialPreviewView(material: material)
        }
        .sheet(isPresented: $showAllNotes) {
            WorkspaceAllNotesView(
                notes: viewModel.notes,
                onOpen: { note in
                    activeNoteDraft = note
                },
                onDelete: { note in
                    viewModel.deleteNote(note)
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showAllMaterials) {
            WorkspaceAllMaterialsView(
                materials: viewModel.materials,
                onOpen: { material in
                    viewModel.openPreview(for: material)
                },
                onToggleAISelection: { material in
                    viewModel.toggleMaterialSelectionForAI(material.id)
                },
                onRename: { material, newTitle in
                    viewModel.renameMaterial(material, to: newTitle)
                },
                onDelete: { material in
                    viewModel.deleteMaterial(material)
                }
            )
            .presentationDetents([.medium, .large])
        }
        .alert("Import Error", isPresented: Binding(
            get: { viewModel.importErrorMessage != nil },
            set: { newValue in
                if !newValue { viewModel.importErrorMessage = nil }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.importErrorMessage ?? "")
        }
        .navigationDestination(item: $summaryRoute) { route in
            SummaryDetailView(
                workspaceId: route.request.workspaceId,
                workspaceTitle: route.request.workspaceTitle,
                workspaceContent: route.request.workspaceContent,
                workspaceColorHex: route.workspaceColorHex,
                sourceItems: route.sourceItems,
                onSummarySaved: {
                    viewModel.registerGeneratedSummaryOutput()
                }
            )
        }
        .navigationDestination(item: $activeNoteDraft) { note in
            WorkspaceNoteEditorView(
                note: note,
                onSave: { saved in
                    viewModel.saveNote(saved)
                },
                onDelete: { toDelete in
                    viewModel.deleteNote(toDelete)
                }
            )
            .environment(\.workspaceThemePalette, workspacePalette)
        }
        .navigationDestination(isPresented: $showAIChat) {
            AIChatView(viewModel: AIChatViewModel(selectedContext: chatContext))
        }
        .navigationDestination(isPresented: $showKnowledgeQuiz) {
            QuizQuestionView(
                workspaceTitle: viewModel.workspace.title,
                workspaceColorHex: viewModel.workspace.workspaceColorHex
            )
        }
        .navigationDestination(isPresented: $showFlashcardSession) {
            FlashcardSessionView(workspaceTitle: viewModel.workspace.title)
        }
        .navigationDestination(isPresented: $showStudyPlan) {
            StudyPlanView(workspaceTitle: viewModel.workspace.title)
        }
        .sheet(item: $comingSoonFeature) { _ in
            ComingSoonFeatureSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .overlay {
            if viewModel.isImporting {
                ZStack {
                    Color.black.opacity(0.08).ignoresSafeArea()
                    ProgressView("Importing material...")
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var chatContext: WorkspaceContext {
        WorkspaceContext(
            workspaceTitle: viewModel.workspace.title,
            sourceTitle: viewModel.workspace.title,
            sourceType: "Workspace",
            description: "Live workspace context including notes, uploaded files, PDFs, documents, and OCR text extracted from photos.",
            visualLabel: "Context: \(viewModel.workspace.title) notes, files, and photos",
            previewSystemImage: viewModel.workspace.iconName,
            referencedMaterials: viewModel.referencedMaterials,
            sourceContents: viewModel.chatSourceContents(),
            aiContextSource: viewModel.aiContextSource
        )
    }

    private var supportedDocumentTypes: [UTType] {
        [.item]
    }

    private var recentActivityItems: [ActivityItem] {
        let noteItems = viewModel.notes.prefix(3).map { note in
            WorkspaceActivityRecord(
                id: note.id,
                kind: .note,
                iconName: "square.and.pencil",
                title: note.title,
                detail: "Note updated in this workspace.",
                occurredAt: note.updatedAt
            )
        }

        let materialItems = viewModel.materials.prefix(3).map { material in
            WorkspaceActivityRecord(
                id: material.id,
                kind: .material,
                iconName: materialIconName(for: material.type),
                title: material.title,
                detail: materialDetailText(for: material),
                occurredAt: material.createdAt
            )
        }

        let merged = (noteItems + materialItems)
            .sorted { $0.occurredAt > $1.occurredAt }
            .prefix(5)

        return merged.map {
            ActivityItem(
                id: $0.id,
                iconName: $0.iconName,
                title: $0.title,
                timestamp: $0.occurredAt.formattedActivityTimestamp,
                detail: $0.detail
            )
        }
    }

    private func materialIconName(for type: StudyMaterialType) -> String {
        switch type {
        case .image:
            return "photo"
        case .pdf, .document, .text:
            return "doc.text"
        case .other:
            return "doc"
        }
    }

    private func materialDetailText(for material: StudyMaterial) -> String {
        let tag = material.type.displayName
        if material.fileSizeInBytes > 0 {
            return "\(material.fileSizeInBytes.formattedByteCount) • \(tag)"
        }
        return tag
    }

    private func handleAction(_ title: String) {
        if title == "Summarise Knowledge" {
            openSummaryFlow()
            return
        }
        if title == "Ask AI" {
            showAIChat = true
            return
        }
        if title == "Quiz" {
            comingSoonFeature = .quiz
            return
        }
        if title == "Flashcards" {
            comingSoonFeature = .flashcards
            return
        }
        if title == "Action Plan" {
            comingSoonFeature = .studyPlan
            return
        }
    }

    private func openSummaryFlow() {
        let sources = viewModel.summarySourceItems()
        summaryRoute = WorkspaceSummaryRoute(
            request: viewModel.workspaceSummaryRequest(),
            workspaceColorHex: viewModel.workspace.workspaceColorHex,
            sourceItems: sources
        )
    }
}

private struct ComingSoonFeatureSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.96),
                    Color(red: 0.94, green: 0.94, blue: 0.93),
                    Color(red: 0.90, green: 0.90, blue: 0.89)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.primary.opacity(0.10))
                    .frame(width: 44, height: 5)
                    .padding(.top, 6)

                Circle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 92, height: 92)
                    .overlay(
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color(red: 0.48, green: 0.48, blue: 0.48))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
                    .padding(.top, 6)

                VStack(spacing: 10) {
                    Text("Coming Soon")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("This study tool is planned for a future update. For now, you can continue using notes, uploads, AI summaries, and chat.")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button(action: { dismiss() }) {
                    Text("Got it")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.52, green: 0.52, blue: 0.52),
                                    Color(red: 0.38, green: 0.38, blue: 0.38)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer(minLength: 8)
            }
            .padding(.bottom, 22)
        }
    }
}

private extension Date {
    var formattedActivityTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

private extension Int64 {
    var formattedByteCount: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}

#Preview {
    ActiveWorkspaceView(studySpace: StudySpace.sampleData[0])
}
