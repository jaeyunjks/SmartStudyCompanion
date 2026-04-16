import SwiftUI

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

    @State private var showActionAlert = false
    @State private var selectedActionTitle = ""
    @State private var showAddSheet = false
    @State private var showSummaryDetail = false
    @State private var showAIChat = false

    private let activityItems: [ActivityItem] = [
        .init(iconName: "doc.text", title: "Key Concepts of Serverless", timestamp: "2h ago", detail: "Exploration of FaaS, cold starts, and event-driven architectures."),
        .init(iconName: "photo", title: "Architecture Diagram", timestamp: "3d ago", detail: "Updated system diagram for scalable compute clusters."),
        .init(iconName: "doc.richtext", title: "Distributed Systems Syllabus", timestamp: "1d ago", detail: "2.4 MB • PDF Document • Core curriculum")
    ]

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
                showAddSheet = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddSheet) {
            WorkspacePlaceholderSheetView(title: "Add to Workspace")
        }
        .navigationDestination(isPresented: $showSummaryDetail) {
            SummaryDetailView(summary: initialSummary)
        }
        .navigationDestination(isPresented: $showAIChat) {
            AIChatView(viewModel: AIChatViewModel(selectedContext: chatContext))
        }
        .alert("Action", isPresented: $showActionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(selectedActionTitle)
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
            previewSystemImage: studySpace.iconName
        )
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
        selectedActionTitle = title
        showActionAlert = true
    }
}

private struct WorkspacePlaceholderSheetView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.bold))
            Text("This is a placeholder screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ActiveWorkspaceView(studySpace: StudySpace.sampleData[0])
}
