import SwiftUI

struct SummaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: SummaryDetailViewModel
    @State private var showFallbackShareSheet = false
    private let workspaceColorHex: String?

    @MainActor
    private var palette: SummaryPalette {
        let accentBase = workspaceColorHex.flatMap(Color.init(hex:)) ?? WorkspaceTheme.accent
        return SummaryPalette(base: accentBase, colorScheme: colorScheme)
    }

    private let keyConceptColumns = [
        GridItem(.adaptive(minimum: 160), spacing: 12)
    ]

    init(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        workspaceColorHex: String? = nil
    ) {
        self.workspaceColorHex = workspaceColorHex
        _viewModel = StateObject(
            wrappedValue: SummaryDetailViewModel(
                workspaceId: workspaceId,
                workspaceTitle: workspaceTitle,
                workspaceContent: workspaceContent
            )
        )
    }

#if DEBUG
    init(previewSummary: StudySummary) {
        self.workspaceColorHex = nil
        _viewModel = StateObject(
            wrappedValue: SummaryDetailViewModel(
                workspaceId: UUID().uuidString,
                workspaceTitle: previewSummary.title,
                workspaceContent: "Preview-only workspace content.",
                initialSummary: previewSummary,
                shouldAutoRequestOnLoad: false
            )
        )
    }
#endif

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            backgroundGlow

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if let summary = viewModel.summary {
                        SummaryHeroSection(summary: summary)

                        MainIdeasCard(ideas: summary.mainIdeas)

                        VisualReferenceCard(
                            title: summary.visualReferenceTitle,
                            caption: summary.visualReferenceCaption,
                            imageName: summary.imageName,
                            imageSystemName: summary.imageSystemName
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Concepts")
                                .font(.system(size: 26, weight: .bold, design: .rounded))

                            LazyVGrid(columns: keyConceptColumns, spacing: 12) {
                                ForEach(summary.keyConcepts) { concept in
                                    KeyConceptCard(concept: concept)
                                }
                            }
                        }

                        ImportantPointsCard(points: summary.importantPoints)

                        SummaryActionButtons(
                            isLoading: viewModel.isLoading,
                            onRegenerate: viewModel.regenerateSummary,
                            onSimplify: viewModel.simplifySummary
                        )
                        .padding(.top, 8)
                        .padding(.bottom, 22)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.isLoading ? "Generating summary..." : "No summary generated yet.")
                                .font(.title3.weight(.bold))
                            Text("We’ll generate a summary from notes in this workspace.")
                                .font(.subheadline)
                                .foregroundStyle(palette.textSecondary)

                            if !viewModel.isLoading {
                                Button("Try Again") {
                                    viewModel.regenerateSummary()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.accent)
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .summaryGlassCard()
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .animation(.spring(response: 0.45, dampingFraction: 0.9), value: viewModel.summary)
            }
            .safeAreaInset(edge: .top) {
                SummaryTopBar(
                    isBookmarked: viewModel.summary?.isBookmarked ?? false,
                    shareText: viewModel.shareSummaryText(),
                    onBack: { dismiss() },
                    onToggleBookmark: viewModel.toggleBookmark,
                    onFallbackShare: { showFallbackShareSheet = true }
                )
            }

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showFallbackShareSheet) {
            SummaryShareSheet(activityItems: [viewModel.shareSummaryText()])
        }
        .task {
            viewModel.loadIfNeeded()
        }
        .environment(\.summaryPalette, palette)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backgroundGlow: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(palette.accentSoft.opacity(0.28))
                    .frame(width: 320)
                    .blur(radius: 90)
                    .position(x: proxy.size.width - 40, y: proxy.size.height - 80)

                Circle()
                    .fill(palette.accent.opacity(0.08))
                    .frame(width: 260)
                    .blur(radius: 80)
                    .position(x: 24, y: 80)
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressView()
                    .tint(palette.accent)
                Text("Generating updated summary...")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .transition(.opacity)
    }
}

#Preview {
    NavigationStack {
        SummaryDetailView(previewSummary: StudySummary.previewSummaries[0])
    }
}
