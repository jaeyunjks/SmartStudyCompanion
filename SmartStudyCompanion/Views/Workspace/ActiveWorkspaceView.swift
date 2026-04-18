import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum WorkspaceTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
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

    let studySpace: StudySpace

    @StateObject private var viewModel: ActiveWorkspaceViewModel

    @State private var showActionAlert = false
    @State private var selectedActionTitle = ""
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
        self.studySpace = studySpace
        _viewModel = StateObject(wrappedValue: ActiveWorkspaceViewModel(studySpace: studySpace))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: WorkspaceTheme.sectionSpacing) {
                    WorkspaceHeaderView(studySpace: studySpace, accent: WorkspaceTheme.accent)

                    WorkspaceProgressCardView(progress: studySpace.progress, accent: WorkspaceTheme.accent)

                    AICompanionSectionView(
                        onPrimaryAction: { handleAction("Summarise Knowledge") },
                        onSecondaryAction: { handleAction($0) }
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
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            .background(WorkspaceTheme.background.ignoresSafeArea())
            .safeAreaInset(edge: .top) {
                WorkspaceTopBarView(
                    title: "Active Study Workspace",
                    onBack: { dismiss() },
                    onMore: { handleAction("More Options") }
                )
            }

            WorkspaceFloatingAddButtonView {
                showImportOptions = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
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
        .navigationDestination(isPresented: $showAIChat) {
            AIChatView(viewModel: AIChatViewModel(selectedContext: chatContext))
        }
        .navigationDestination(isPresented: $showKnowledgeQuiz) {
            QuizQuestionView(workspaceTitle: studySpace.title)
        }
        .navigationDestination(isPresented: $showFlashcardSession) {
            FlashcardSessionView(workspaceTitle: studySpace.title)
        }
        .navigationDestination(isPresented: $showStudyPlan) {
            StudyPlanView(workspaceTitle: studySpace.title)
        }
        .alert("Action", isPresented: $showActionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(selectedActionTitle)
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
        if studySpace.title.localizedCaseInsensitiveContains("cloud") {
            return StudySummary.mockSummaries[0]
        }
        return StudySummary.mockSummaries[1]
    }

    private var chatContext: WorkspaceContext {
        WorkspaceContext(
            workspaceTitle: studySpace.title,
            sourceTitle: "Comparison Table",
            sourceType: "PDF",
            description: "Reference extracted from your latest uploaded material.",
            visualLabel: "Context: \(studySpace.title) notes and reference table",
            previewSystemImage: studySpace.iconName,
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
        selectedActionTitle = title
        showActionAlert = true
    }
}

#Preview {
    ActiveWorkspaceView(studySpace: StudySpace.sampleData[0])
}
