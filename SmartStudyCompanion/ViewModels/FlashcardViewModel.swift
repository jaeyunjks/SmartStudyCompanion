//
//  FlashcardViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for flashcard operations (generate, fetch, study, update)
class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentCard: Flashcard?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cardIndex: Int = 0
    @Published var isFlipped = false
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Generate Flashcards
    
    /// Generate flashcards from a PDF
    @MainActor
    func generateFlashcards(pdfFileId: String, count: Int, difficulty: Flashcard.Difficulty) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let generated = try await apiService.generateFlashcards(
                pdfFileId: pdfFileId,
                count: count,
                difficulty: difficulty
            )
            
            self.flashcards = generated
            if !generated.isEmpty {
                self.currentCard = generated[0]
                self.cardIndex = 0
            }
            
            // Cache to CoreData
            try coreDataManager.saveFlashcards(generated)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            loadFlashcardsFromCache(pdfFileId: pdfFileId)
        } catch {
            self.errorMessage = "Failed to generate flashcards"
            loadFlashcardsFromCache(pdfFileId: pdfFileId)
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Flashcards
    
    /// Fetch flashcards for a PDF
    @MainActor
    func fetchFlashcards(for pdfFileId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await apiService.fetchFlashcards(for: pdfFileId)
            self.flashcards = fetched
            if !fetched.isEmpty {
                self.currentCard = fetched[0]
                self.cardIndex = 0
            }
            
            try coreDataManager.saveFlashcards(fetched)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            loadFlashcardsFromCache(pdfFileId: pdfFileId)
        } catch {
            self.errorMessage = "Failed to fetch flashcards"
            loadFlashcardsFromCache(pdfFileId: pdfFileId)
        }
        
        isLoading = false
    }
    
    // MARK: - Study Operations
    
    /// Mark card as correct and move to next
    func markCorrect() {
        guard var card = currentCard else { return }
        
        card.reviewCount += 1
        card.correctCount += 1
        card.lastReviewedAt = Date()
        
        updateFlashcard(card)
        moveToNextCard()
    }
    
    /// Mark card as incorrect and move to next
    func markIncorrect() {
        guard var card = currentCard else { return }
        
        card.reviewCount += 1
        card.lastReviewedAt = Date()
        
        updateFlashcard(card)
        moveToNextCard()
    }
    
    /// Move to next flashcard
    func moveToNextCard() {
        if cardIndex + 1 < flashcards.count {
            cardIndex += 1
            currentCard = flashcards[cardIndex]
            isFlipped = false
        }
    }
    
    /// Move to previous flashcard
    func moveToPreviousCard() {
        if cardIndex > 0 {
            cardIndex -= 1
            currentCard = flashcards[cardIndex]
            isFlipped = false
        }
    }
    
    /// Toggle card flip
    func toggleFlip() {
        isFlipped.toggle()
    }
    
    // MARK: - Update Flashcard
    
    /// Update a flashcard
    private func updateFlashcard(_ flashcard: Flashcard) {
        Task {
            do {
                let updated = try await apiService.updateFlashcard(id: flashcard.id, updatedFlashcard: flashcard)
                try coreDataManager.updateFlashcard(updated)
                
                // Update in array
                if let index = flashcards.firstIndex(where: { $0.id == updated.id }) {
                    flashcards[index] = updated
                }
            } catch {
                print("Error updating flashcard: \(error)")
            }
        }
    }
    
    // MARK: - Cache Operations
    
    /// Load flashcards from CoreData cache
    private func loadFlashcardsFromCache(pdfFileId: String) {
        let cached = coreDataManager.fetchFlashcards(for: pdfFileId)
        self.flashcards = cached
        if !cached.isEmpty {
            self.currentCard = cached[0]
            self.cardIndex = 0
        }
    }
}
