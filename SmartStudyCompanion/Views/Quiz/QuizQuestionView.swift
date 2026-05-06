import SwiftUI
import UIKit

struct QuizQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: QuizQuestionViewModel
    @State private var showQuizCompleteAlert = false
    @State private var showQuizSettings = false
    @State private var selectedQuestionCount = 5
    @State private var selectedDifficulty = "medium"

    private let workspaceColorHex: String?

    @MainActor
    init(viewModel: QuizQuestionViewModel, workspaceColorHex: String? = nil) {
        self.workspaceColorHex = workspaceColorHex
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init(workspaceTitle: String = "Knowledge", workspaceColorHex: String? = nil) {
        self.workspaceColorHex = workspaceColorHex
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

    @MainActor
    private var palette: QuizPalette {
        let accentBase = workspaceColorHex.flatMap(Color.init(hex:)) ?? WorkspaceTheme.accent
        return QuizPalette(base: accentBase, colorScheme: colorScheme)
    }

    private var difficultyLabel: String {
        selectedDifficulty.capitalized
    }

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    QuizProgressView(progress: viewModel.progress)

                    HStack(spacing: 8) {
                        settingsChip(title: "\(selectedQuestionCount) Questions")
                        settingsChip(title: difficultyLabel)
                    }

                    if let question = viewModel.currentQuestion {
                        Text(question.questionText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
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
                            .tint(palette.accent)
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
                QuizTopBar(
                    onClose: { dismiss() },
                    onOpenSettings: { showQuizSettings = true }
                )
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
                        colors: [palette.background.opacity(0), palette.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .task {
            selectedQuestionCount = viewModel.configuredQuestionCount
            selectedDifficulty = viewModel.configuredDifficulty
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
        .sheet(isPresented: $showQuizSettings) {
            QuizSettingsSheet(
                questionCount: $selectedQuestionCount,
                difficulty: $selectedDifficulty,
                onApply: {
                    Task {
                        await viewModel.regenerateQuiz(questionCount: selectedQuestionCount, difficulty: selectedDifficulty)
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .environment(\.quizPalette, palette)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func settingsChip(title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(palette.accentSubtle)
            .clipShape(Capsule())
    }

    private var decorativeBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(palette.accentSoft.opacity(0.24))
                    .frame(width: 320)
                    .blur(radius: 90)
                    .position(x: -20, y: -40)

                Circle()
                    .fill(palette.accent.opacity(0.08))
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

private struct QuizSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var questionCount: Int
    @Binding var difficulty: String
    let onApply: () -> Void

    private let availableQuestionCounts = [5, 10, 15, 20]
    private let difficulties = ["easy", "medium", "hard"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Number of Questions") {
                    Picker("Questions", selection: $questionCount) {
                        ForEach(availableQuestionCounts, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Difficulty") {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { level in
                            Text(level.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Quiz Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizQuestionView(workspaceTitle: "41001 Cloud Computing")
    }
}