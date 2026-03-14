//
//  CoreDataManager.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import CoreData

/// Manages all CoreData operations for offline caching
class CoreDataManager {
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    // MARK: - Properties
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SmartStudyCompanion")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unable to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Save Methods
    
    /// Save changes to CoreData
    func save() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Summary Methods
    
    /// Save summary to CoreData
    func saveSummary(_ summary: Summary) throws {
        let cdSummary = CDSummary(context: viewContext)
        cdSummary.id = summary.id
        cdSummary.userId = summary.userId
        cdSummary.pdfFileId = summary.pdfFileId
        cdSummary.title = summary.title
        cdSummary.content = summary.content
        cdSummary.keyPoints = summary.keyPoints
        cdSummary.generatedAt = summary.generatedAt
        cdSummary.wordCount = Int32(summary.wordCount)
        cdSummary.readingTime = Int32(summary.readingTime)
        
        try save()
    }
    
    /// Fetch summary from CoreData
    func fetchSummary(pdfFileId: String) -> Summary? {
        let request = NSFetchRequest<CDSummary>(entityName: "CDSummary")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        
        do {
            let results = try viewContext.fetch(request)
            return results.first?.toModel()
        } catch {
            print("Error fetching summary: \(error)")
            return nil
        }
    }
    
    // MARK: - Flashcard Methods
    
    /// Save flashcards to CoreData
    func saveFlashcards(_ flashcards: [Flashcard]) throws {
        for flashcard in flashcards {
            let cdFlashcard = CDFlashcard(context: viewContext)
            cdFlashcard.id = flashcard.id
            cdFlashcard.userId = flashcard.userId
            cdFlashcard.pdfFileId = flashcard.pdfFileId
            cdFlashcard.front = flashcard.front
            cdFlashcard.back = flashcard.back
            cdFlashcard.difficulty = flashcard.difficulty.rawValue
            cdFlashcard.createdAt = flashcard.createdAt
            cdFlashcard.lastReviewedAt = flashcard.lastReviewedAt
            cdFlashcard.reviewCount = Int32(flashcard.reviewCount)
            cdFlashcard.correctCount = Int32(flashcard.correctCount)
        }
        
        try save()
    }
    
    /// Fetch flashcards for a PDF
    func fetchFlashcards(for pdfFileId: String) -> [Flashcard] {
        let request = NSFetchRequest<CDFlashcard>(entityName: "CDFlashcard")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDFlashcard.createdAt, ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            return results.map { $0.toModel() }
        } catch {
            print("Error fetching flashcards: \(error)")
            return []
        }
    }
    
    /// Update flashcard
    func updateFlashcard(_ flashcard: Flashcard) throws {
        let request = NSFetchRequest<CDFlashcard>(entityName: "CDFlashcard")
        request.predicate = NSPredicate(format: "id == %@", flashcard.id)
        
        if let cdFlashcard = try viewContext.fetch(request).first {
            cdFlashcard.front = flashcard.front
            cdFlashcard.back = flashcard.back
            cdFlashcard.difficulty = flashcard.difficulty.rawValue
            cdFlashcard.lastReviewedAt = flashcard.lastReviewedAt
            cdFlashcard.reviewCount = Int32(flashcard.reviewCount)
            cdFlashcard.correctCount = Int32(flashcard.correctCount)
            
            try save()
        }
    }
    
    // MARK: - Quiz Methods
    
    /// Save quiz to CoreData
    func saveQuiz(_ quiz: Quiz) throws {
        let cdQuiz = CDQuiz(context: viewContext)
        cdQuiz.id = quiz.id
        cdQuiz.userId = quiz.userId
        cdQuiz.pdfFileId = quiz.pdfFileId
        cdQuiz.title = quiz.title
        cdQuiz.createdAt = quiz.createdAt
        cdQuiz.timeLimit = Int32(quiz.timeLimit ?? 0)
        cdQuiz.passingScore = Int32(quiz.passingScore)
        
        try save()
    }
    
    /// Fetch quiz
    func fetchQuiz(id: String) -> Quiz? {
        let request = NSFetchRequest<CDQuiz>(entityName: "CDQuiz")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try viewContext.fetch(request)
            return results.first?.toModel()
        } catch {
            print("Error fetching quiz: \(error)")
            return nil
        }
    }
    
    /// Fetch quizzes for a PDF
    func fetchQuizzes(for pdfFileId: String) -> [Quiz] {
        let request = NSFetchRequest<CDQuiz>(entityName: "CDQuiz")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDQuiz.createdAt, ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            return results.map { $0.toModel() }
        } catch {
            print("Error fetching quizzes: \(error)")
            return []
        }
    }
    
    // MARK: - Progress Methods
    
    /// Save progress to CoreData
    func saveProgress(_ progress: Progress) throws {
        let request = NSFetchRequest<CDProgress>(entityName: "CDProgress")
        request.predicate = NSPredicate(format: "id == %@", progress.id)
        
        let cdProgress: CDProgress
        if let existing = try viewContext.fetch(request).first {
            cdProgress = existing
        } else {
            cdProgress = CDProgress(context: viewContext)
        }
        
        cdProgress.id = progress.id
        cdProgress.userId = progress.userId
        cdProgress.pdfFileId = progress.pdfFileId
        cdProgress.totalTimeSpent = Int32(progress.totalTimeSpent)
        cdProgress.cardsStudied = Int32(progress.cardsStudied)
        cdProgress.cardsRemaining = Int32(progress.cardsRemaining)
        cdProgress.quizzesCompleted = Int32(progress.quizzesCompleted)
        cdProgress.averageScore = progress.averageScore
        cdProgress.lastStudyDate = progress.lastStudyDate
        cdProgress.studyStreak = Int32(progress.studyStreak)
        cdProgress.totalCards = Int32(progress.totalCards)
        cdProgress.masteredCards = Int32(progress.masteredCards)
        
        try save()
    }
    
    /// Fetch progress for a PDF
    func fetchProgress(for pdfFileId: String) -> Progress? {
        let request = NSFetchRequest<CDProgress>(entityName: "CDProgress")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        
        do {
            let results = try viewContext.fetch(request)
            return results.first?.toModel()
        } catch {
            print("Error fetching progress: \(error)")
            return nil
        }
    }
    
    // MARK: - Delete Methods
    
    /// Delete a summary
    func deleteSummary(pdfFileId: String) throws {
        let request = NSFetchRequest<CDSummary>(entityName: "CDSummary")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        
        if let summary = try viewContext.fetch(request).first {
            viewContext.delete(summary)
            try save()
        }
    }
    
    /// Delete flashcards for a PDF
    func deleteFlashcards(for pdfFileId: String) throws {
        let request = NSFetchRequest<CDFlashcard>(entityName: "CDFlashcard")
        request.predicate = NSPredicate(format: "pdfFileId == %@", pdfFileId)
        
        let flashcards = try viewContext.fetch(request)
        for flashcard in flashcards {
            viewContext.delete(flashcard)
        }
        
        try save()
    }
    
    /// Delete quiz
    func deleteQuiz(id: String) throws {
        let request = NSFetchRequest<CDQuiz>(entityName: "CDQuiz")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let quiz = try viewContext.fetch(request).first {
            viewContext.delete(quiz)
            try save()
        }
    }
}
