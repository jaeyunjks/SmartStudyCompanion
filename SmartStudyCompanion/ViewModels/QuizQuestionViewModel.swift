import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizQuestionViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedOptionID: String?
    @Published var hasCheckedAnswer = false
    @Published var score = 0
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let provider: QuizProviderProtocol
    private let request: QuizGenerationRequest

    var onQuizCompleted: ((Int, Int) -> Void)?

    init(
        provider: QuizProviderProtocol,
        request: QuizGenerationRequest
    ) {
        self.provider = provider
        self.request = request
    }

    convenience init() {
        self.init(
            provider: MockQuizService(),
            request: QuizGenerationRequest(
                pdfFileId: "mock_pdf",
                questionCount: 5,
                difficulty: "medium",
                workspaceTitle: "Knowledge"
            )
        )
    }

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: QuizProgress {
        QuizProgress(current: currentQuestionIndex + 1, total: max(questions.count, 1))
    }

    var isCurrentSelectionCorrect: Bool {
        guard let currentQuestion, let selectedOptionID else { return false }
        return currentQuestion.correctOptionID == selectedOptionID
    }

    var ctaLabel: String {
        if !hasCheckedAnswer {
            return "Check Answer"
        }
        return isLastQuestion ? "See Results" : "Next Question"
    }

    var canTapPrimaryAction: Bool {
        hasCheckedAnswer || selectedOptionID != nil
    }

    var answerState: QuizAnswerState {
        guard let selectedOptionID else { return .unanswered }
        if !hasCheckedAnswer {
            return .selected
        }
        return isOptionCorrect(optionID: selectedOptionID) ? .correct : .incorrect
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }

    func loadQuiz() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await provider.generateQuiz(request: request)
            withAnimation(.easeInOut(duration: 0.25)) {
                questions = response.questions
                currentQuestionIndex = 0
                selectedOptionID = nil
                hasCheckedAnswer = false
                score = 0
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to load quiz questions."
        }

        isLoading = false
    }

    func selectOption(_ optionID: String) {
        guard !hasCheckedAnswer else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
            selectedOptionID = optionID
        }
    }

    func primaryActionTapped() {
        if !hasCheckedAnswer {
            checkAnswer()
        } else {
            goToNextQuestionOrFinish()
        }
    }

    func resetCurrentQuestion() {
        selectedOptionID = nil
        hasCheckedAnswer = false
    }

    func isOptionCorrect(optionID: String) -> Bool {
        currentQuestion?.correctOptionID == optionID
    }

    private func checkAnswer() {
        guard selectedOptionID != nil else { return }
        hasCheckedAnswer = true

        if isCurrentSelectionCorrect {
            score += 1
        }
    }

    private func goToNextQuestionOrFinish() {
        if isLastQuestion {
            onQuizCompleted?(score, questions.count)
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            currentQuestionIndex += 1
            selectedOptionID = nil
            hasCheckedAnswer = false
        }
    }
}
