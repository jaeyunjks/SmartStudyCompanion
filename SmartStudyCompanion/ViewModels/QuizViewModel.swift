//
//  QuizViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for quiz operations (generate, fetch, submit)
class QuizViewModel: ObservableObject {
    @Published var quiz: Quiz?
    @Published var quizzes: [Quiz] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userAnswers: [String: String] = [:]
    @Published var quizResult: QuizSubmissionResponse?
    @Published var currentQuestionIndex: Int = 0
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Generate Quiz
    
    /// Generate a new quiz for a PDF
    @MainActor
    func generateQuiz(pdfFileId: String, questionCount: Int, difficulty: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let generatedQuiz = try await apiService.generateQuiz(
                pdfFileId: pdfFileId,
                questionCount: questionCount,
                difficulty: difficulty
            )
            
            self.quiz = generatedQuiz
            self.quizzes.append(generatedQuiz)
            self.userAnswers = [:]
            self.currentQuestionIndex = 0
            
            // Cache to CoreData
            try coreDataManager.saveQuiz(generatedQuiz)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to generate quiz"
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Quiz
    
    /// Fetch a specific quiz
    @MainActor
    func fetchQuiz(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedQuiz = try await apiService.fetchQuiz(id: id)
            self.quiz = fetchedQuiz
            self.userAnswers = [:]
            self.currentQuestionIndex = 0
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            // Try loading from cache
            if let cached = coreDataManager.fetchQuiz(id: id) {
                self.quiz = cached
            }
        } catch {
            self.errorMessage = "Failed to fetch quiz"
        }
        
        isLoading = false
    }
    
    /// Fetch all quizzes for a PDF
    @MainActor
    func fetchQuizzes(for pdfFileId: String) async {
        isLoading = true
        errorMessage = nil
        
        let fetched = coreDataManager.fetchQuizzes(for: pdfFileId)
        self.quizzes = fetched
        
        isLoading = false
    }
    
    // MARK: - Quiz Progress
    
    /// Save answer for a question
    func saveAnswer(questionId: String, answer: String) {
        userAnswers[questionId] = answer
    }
    
    /// Move to next question
    func moveToNextQuestion() {
        guard let quiz = quiz else { return }
        if currentQuestionIndex + 1 < quiz.questions.count {
            currentQuestionIndex += 1
        }
    }
    
    /// Move to previous question
    func moveToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    /// Check if can proceed to next question (answer is provided)
    func canProceed() -> Bool {
        guard let quiz = quiz else { return false }
        let currentQuestion = quiz.questions[currentQuestionIndex]
        return userAnswers[currentQuestion.id] != nil
    }
    
    // MARK: - Submit Quiz
    
    /// Submit quiz answers
    @MainActor
    func submitQuiz() async {
        guard let quiz = quiz else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await apiService.submitQuizAnswers(
                quizId: quiz.id,
                answers: userAnswers
            )
            
            self.quizResult = result
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to submit quiz"
        }
        
        isLoading = false
    }
    
    /// Reset quiz state
    func resetQuiz() {
        quiz = nil
        userAnswers = [:]
        currentQuestionIndex = 0
        quizResult = nil
        errorMessage = nil
    }
}
