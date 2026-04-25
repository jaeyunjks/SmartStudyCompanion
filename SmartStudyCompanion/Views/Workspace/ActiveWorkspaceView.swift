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
            ? UIColor(red: 0.09, green: 0.13, blue: 0.12, alpha: 1)
            : UIColor(red: 0.96, green: 0.97, blue: 0.95, alpha: 1)
    })
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.17, blue: 0.16, alpha: 1)
            : UIColor(red: 0.94, green: 0.96, blue: 0.95, alpha: 1)
    })
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 20
    static let sectionSpacing: CGFloat = 22

    static func surfaceSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.14, green: 0.18, blue: 0.17)
            : Color(red: 0.95, green: 0.97, blue: 0.96)
    }

    static func surfaceTertiary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.17, green: 0.22, blue: 0.20)
            : Color(red: 0.92, green: 0.95, blue: 0.93)
    }
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let timestamp: String
    let detail: String
}

struct ActiveWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: ActiveWorkspaceViewModel

    @State private var showWorkspaceMenu = false
    @State private var showDeleteWorkspaceConfirmation = false
    @State private var showEditWorkspaceSheet = false
    @State private var activeNoteDraft: WorkspaceNote?
    @State private var showSummaryDetail = false
    @State private var showAllNotes = false
    @State private var showAIChat = false
    @State private var showKnowledgeQuiz = false
    @State private var showFlashcardSession = false
    @State private var showStudyPlan = false
    @State private var showImportOptions = false
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(studySpace: StudySpace) {
        _viewModel = StateObject(
            wrappedValue: ActiveWorkspaceViewModel(
                studySpace: studySpace,
                storageService: .shared,
                noteStorageService: .shared,
                store: .shared
            )
        )
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
                                noteCount: viewModel.noteCount,
                                aiOutputCount: viewModel.aiOutputCount
                            )

                            WorkspaceSectionLabel(title: "Capture & AI")
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
            selection: $selectedPhotoItem,
            matching: .images,
            preferredItemEncoding: .automatic
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await viewModel.importPhoto(data: data, fileName: nil)
                } else {
                    viewModel.importErrorMessage = "Could not load the selected photo."
                }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: supportedDocumentTypes,
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task { await viewModel.importDocument(from: url) }
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
                viewModel.updateWorkspaceStatus("Active")
            }
            Button("Set as Inactive") {
                viewModel.updateWorkspaceStatus("Inactive")
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
        .navigationDestination(isPresented: $showSummaryDetail) {
            SummaryDetailView(summary: initialSummary)
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
            QuizQuestionView(workspaceTitle: viewModel.workspace.title)
        }
        .navigationDestination(isPresented: $showFlashcardSession) {
            FlashcardSessionView(workspaceTitle: viewModel.workspace.title)
        }
        .navigationDestination(isPresented: $showStudyPlan) {
            StudyPlanView(workspaceTitle: viewModel.workspace.title)
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

    private var initialSummary: StudySummary {
        if viewModel.workspace.title.localizedCaseInsensitiveContains("cloud") {
            return StudySummary.mockSummaries[0]
        }
        return StudySummary.mockSummaries[1]
    }

    private var chatContext: WorkspaceContext {
        WorkspaceContext(
            workspaceTitle: viewModel.workspace.title,
            sourceTitle: "Comparison Table",
            sourceType: "PDF",
            description: "Reference extracted from your latest uploaded material.",
            visualLabel: "Context: \(viewModel.workspace.title) notes and reference table",
            previewSystemImage: viewModel.workspace.iconName,
            referencedMaterials: viewModel.referencedMaterials,
            aiContextSource: viewModel.aiContextSource
        )
    }

    private var supportedDocumentTypes: [UTType] {
        [
            .pdf,
            .plainText,
            .text,
            UTType(filenameExtension: "doc"),
            UTType(filenameExtension: "docx"),
            .rtf
        ].compactMap { $0 }
    }

    private var recentActivityItems: [ActivityItem] {
        let noteItems = viewModel.notes.prefix(3).map { note in
            ActivityItem(
                iconName: "square.and.pencil",
                title: note.title,
                timestamp: note.updatedAt.formattedActivityTimestamp,
                detail: "Note updated in this workspace."
            )
        }

        let materialItems = viewModel.materials.prefix(3).map { material in
            ActivityItem(
                iconName: materialIconName(for: material.type),
                title: material.title,
                timestamp: material.createdAt.formattedActivityTimestamp,
                detail: materialDetailText(for: material)
            )
        }

        return Array((noteItems + materialItems).prefix(5))
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
            showSummaryDetail = true
            return
        }
        if title == "Ask AI" {
            showAIChat = true
            return
        }
        if title == "Quiz" {
            showKnowledgeQuiz = true
            return
        }
        if title == "Flashcards" {
            showFlashcardSession = true
            return
        }
        if title == "Action Plan" {
            showStudyPlan = true
            return
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
