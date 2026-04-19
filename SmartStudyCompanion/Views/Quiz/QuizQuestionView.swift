import SwiftUI
import UIKit

struct QuizQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: QuizQuestionViewModel
    @State private var showQuizCompleteAlert = false

    @MainActor
    init(viewModel: QuizQuestionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init(workspaceTitle: String = "Knowledge") {
        _viewModel = StateObject(
            wrappedValue: QuizQuestionViewModel(
                provider: MockQuizService(),
                request: QuizGenerationRequest(
                    pdfFileId: "mock_pdf",
                    questionCount: 5,
                    difficulty: "medium",
                    workspaceTitle: workspaceTitle,
                    preferredTopics: ["cloud", "databases", "systems"]
                )
            )
        )
    }

    var body: some View {
        ZStack {
            QuizTheme.background
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    QuizProgressView(progress: viewModel.progress)

                    if let question = viewModel.currentQuestion {
                        Text(question.questionText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineSpacing(3)
                            .padding(.bottom, 4)

                        VStack(spacing: 12) {
                            ForEach(question.options) { option in
                                QuizOptionCard(
                                    option: option,
                                    isSelected: viewModel.selectedOptionID == option.id,
                                    hasCheckedAnswer: viewModel.hasCheckedAnswer,
                                    isCorrectOption: viewModel.isOptionCorrect(optionID: option.id),
                                    onTap: {
                                        viewModel.selectOption(option.id)
                                    }
                                )
                            }
                        }

                        if viewModel.hasCheckedAnswer {
                            QuizExplanationCard(
                                isCorrect: viewModel.isCurrentSelectionCorrect,
                                explanation: question.explanation
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    } else if viewModel.isLoading {
                        ProgressView("Loading quiz...")
                            .tint(QuizTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text(viewModel.errorMessage ?? "No quiz questions available.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 100)
                .animation(.easeInOut(duration: 0.25), value: viewModel.hasCheckedAnswer)
            }
            .safeAreaInset(edge: .top) {
                QuizTopBar(onClose: { dismiss() })
                    .padding(.top, 4)
            }
            .safeAreaInset(edge: .bottom) {
                QuizBottomActionBar(
                    title: viewModel.ctaLabel,
                    isEnabled: viewModel.canTapPrimaryAction,
                    action: {
                        viewModel.primaryActionTapped()
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [QuizTheme.background.opacity(0), QuizTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .task {
            if viewModel.questions.isEmpty {
                await viewModel.loadQuiz()
            }
        }
        .onChange(of: viewModel.answerState) { _, newState in
            switch newState {
            case .correct:
                triggerHaptic(success: true)
            case .incorrect:
                triggerHaptic(success: false)
            default:
                break
            }
        }
        .onAppear {
            viewModel.onQuizCompleted = { _, _ in
                showQuizCompleteAlert = true
            }
        }
        .alert("Quiz Complete", isPresented: $showQuizCompleteAlert) {
            Button("Done", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("You scored \(viewModel.score) out of \(viewModel.questions.count).")
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var decorativeBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(QuizTheme.accentSoft.opacity(0.30))
                    .frame(width: 320)
                    .blur(radius: 90)
                    .position(x: -20, y: -40)

                Circle()
                    .fill(QuizTheme.accent.opacity(0.08))
                    .frame(width: 360)
                    .blur(radius: 110)
                    .position(x: proxy.size.width + 50, y: proxy.size.height - 80)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private func triggerHaptic(success: Bool) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(success ? .success : .error)
    }
}

#Preview {
    NavigationStack {
        QuizQuestionView(workspaceTitle: "41001 Cloud Computing")
    }
}
