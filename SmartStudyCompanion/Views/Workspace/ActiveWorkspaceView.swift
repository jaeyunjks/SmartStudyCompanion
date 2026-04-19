import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum WorkspaceTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let deepAccent = Color(red: 0.16, green: 0.43, blue: 0.33)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let mintTint = Color(red: 0.91, green: 0.97, blue: 0.94)
    static let background = Color(red: 0.96, green: 0.97, blue: 0.95)
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 20
    static let sectionSpacing: CGFloat = 22
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

    @StateObject private var viewModel: ActiveWorkspaceViewModel

    @State private var showWorkspaceMenu = false
    @State private var showDeleteWorkspaceConfirmation = false
    @State private var showEditWorkspaceSheet = false
    @State private var activeNoteDraft: WorkspaceNote?
    @State private var showSummaryDetail = false
    @State private var showAIChat = false
    @State private var showKnowledgeQuiz = false
    @State private var showFlashcardSession = false
    @State private var showStudyPlan = false
    @State private var showImportOptions = false
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    private let activityItems: [ActivityItem] = [
        .init(iconName: "doc.text", title: "Key Concepts of Serverless", timestamp: "2h ago", detail: "Exploration of FaaS, cold starts, and event-driven architectures."),
        .init(iconName: "photo", title: "Architecture Diagram", timestamp: "3d ago", detail: "Updated system diagram for scalable compute clusters."),
        .init(iconName: "doc.richtext", title: "Distributed Systems Syllabus", timestamp: "1d ago", detail: "2.4 MB • PDF Document • Core curriculum")
    ]

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
        GeometryReader { geometry in
            let topInset = geometry.safeAreaInsets.top
            let bottomInset = geometry.safeAreaInsets.bottom

            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [
                        WorkspaceTheme.background,
                        WorkspaceTheme.mintTint.opacity(0.38)
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
                            WorkspaceOverviewCardView(
                                studySpace: viewModel.workspace,
                                materialCount: viewModel.materialCount,
                                noteCount: viewModel.noteCount,
                                aiOutputCount: viewModel.aiOutputCount
                            )

                            WorkspaceStudyToolsSectionView(
                                onCreateNote: { activeNoteDraft = viewModel.makeDraftNote() },
                                onPrimaryAction: { handleAction("Summarise Knowledge") },
                                onSecondaryAction: { handleAction($0) }
                            )

                            WorkspaceNotesSectionView(
                                notes: viewModel.notes,
                                onCreateNote: { activeNoteDraft = viewModel.makeDraftNote() },
                                onSelectNote: { note in activeNoteDraft = note }
                            )

                            WorkspaceMaterialsSectionView(
                                materials: viewModel.materials,
                                onTapMaterial: { material in
                                    viewModel.openPreview(for: material)
                                },
                                onToggleAISelection: { material in
                                    viewModel.toggleMaterialSelectionForAI(material.id)
                                }
                            )

                            RecentActivitySectionView(items: activityItems)
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
            CreateStudySpaceView(initialSpace: viewModel.workspace, onCreate: { title, icon, category, description, status in
                viewModel.editWorkspace(title: title, iconName: icon, category: category, description: description, status: status)
                showEditWorkspaceSheet = false
            })
        }
        .sheet(item: $viewModel.selectedMaterialForPreview) { material in
            WorkspaceMaterialPreviewView(material: material)
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
            WorkspaceNoteEditorView(note: note, onSave: { saved in
                viewModel.saveNote(saved)
            })
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

#Preview {
    ActiveWorkspaceView(studySpace: StudySpace.sampleData[0])
}
