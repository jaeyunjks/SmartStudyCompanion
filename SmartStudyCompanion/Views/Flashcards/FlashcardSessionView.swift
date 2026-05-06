import SwiftUI

struct FlashcardSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FlashcardSessionViewModel

    @MainActor
    init(viewModel: FlashcardSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init(workspaceTitle: String) {
        _viewModel = StateObject(wrappedValue: FlashcardSessionViewModel(workspaceTitle: workspaceTitle))
    }

    var body: some View {
        ZStack {
            FlashcardSessionTheme.background
                .ignoresSafeArea()

            decorativeBackground

            Group {
                switch viewModel.sessionState {
                case .loading:
                    ProgressView("Loading flashcards...")
                        .tint(FlashcardSessionTheme.accent)
                case .error(let message):
                    VStack(spacing: 12) {
                        Text(message)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            Task { await viewModel.loadSession() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FlashcardSessionTheme.accent)
                    }
                case .completed(let summary):
                    FlashcardSessionCompletionView(
                        summary: summary,
                        onRestart: { viewModel.restartSession() },
                        onClose: { dismiss() }
                    )
                case .active:
                    content
                }
            }
        }
        .safeAreaInset(edge: .top) {
            FlashcardTopBar(
                selectedDifficulty: viewModel.selectedDifficulty,
                onBack: { dismiss() },
                onSelectDifficulty: { difficulty in
                    viewModel.selectDifficulty(difficulty)
                }
            )
            .padding(.top, 4)
        }
        .task {
            if viewModel.flashcards.isEmpty {
                await viewModel.loadSession()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            FlashcardProgressSection(
                progressText: viewModel.progressText,
                moduleLabel: viewModel.moduleLabel,
                progressValue: viewModel.progressValue
            )

            Spacer(minLength: 0)

            if let card = viewModel.currentCard {
                FlashcardCardView(
                    card: card,
                    isRevealed: viewModel.isRevealed,
                    onTap: { viewModel.toggleReveal() }
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 120)
        .safeAreaInset(edge: .bottom) {
            FlashcardActionButtons(
                isEnabled: viewModel.canReviewActions,
                onReviewAgain: { viewModel.markReviewAgain() },
                onGotIt: { viewModel.markKnown() }
            )
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [FlashcardSessionTheme.background.opacity(0), FlashcardSessionTheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var decorativeBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(FlashcardSessionTheme.accentSoft.opacity(0.32))
                    .frame(width: 300)
                    .blur(radius: 90)
                    .position(x: -20, y: 80)

                Circle()
                    .fill(FlashcardSessionTheme.accent.opacity(0.08))
                    .frame(width: 360)
                    .blur(radius: 110)
                    .position(x: proxy.size.width + 40, y: proxy.size.height - 120)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardSessionView(workspaceTitle: "Cloud Infrastructure Module")
    }
}
