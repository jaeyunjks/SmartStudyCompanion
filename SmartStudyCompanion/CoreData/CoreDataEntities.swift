//
//  CoreDataEntities.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import CoreData

// MARK: - Summary Entity
@objc(CDSummary)
public class CDSummary: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var pdfFileId: String
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var keyPoints: [String]
    @NSManaged public var generatedAt: Date
    @NSManaged public var wordCount: Int32
    @NSManaged public var readingTime: Int32
    
    func toModel() -> Summary {
        Summary(
            id: self.id,
            userId: self.userId,
            pdfFileId: self.pdfFileId,
            title: self.title,
            content: self.content,
            keyPoints: self.keyPoints,
            generatedAt: self.generatedAt,
            wordCount: Int(self.wordCount),
            readingTime: Int(self.readingTime)
        )
    }
}

// MARK: - Flashcard Entity
@objc(CDFlashcard)
public class CDFlashcard: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var pdfFileId: String
    @NSManaged public var setId: String?
    @NSManaged public var front: String
    @NSManaged public var back: String
    @NSManaged public var difficulty: String
    @NSManaged public var createdAt: Date
    @NSManaged public var lastReviewedAt: Date?
    @NSManaged public var reviewCount: Int32
    @NSManaged public var correctCount: Int32
    
    func toModel() -> Flashcard {
        Flashcard(
            id: self.id,
            userId: self.userId,
            pdfFileId: self.pdfFileId,
            setId: self.setId,
            front: self.front,
            back: self.back,
            difficulty: Flashcard.Difficulty(rawValue: self.difficulty) ?? .medium,
            createdAt: self.createdAt,
            lastReviewedAt: self.lastReviewedAt,
            reviewCount: Int(self.reviewCount),
            correctCount: Int(self.correctCount)
        )
    }
}

// MARK: - Quiz Entity
@objc(CDQuiz)
public class CDQuiz: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var pdfFileId: String
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date
    @NSManaged public var timeLimit: Int32
    @NSManaged public var passingScore: Int32
    
    func toModel() -> Quiz {
        Quiz(
            id: self.id,
            userId: self.userId,
            pdfFileId: self.pdfFileId,
            title: self.title,
            questions: [],
            createdAt: self.createdAt,
            timeLimit: self.timeLimit > 0 ? Int(self.timeLimit) : nil,
            passingScore: Int(self.passingScore)
        )
    }
}

// MARK: - Progress Entity
@objc(CDProgress)
public class CDProgress: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var pdfFileId: String
    @NSManaged public var totalTimeSpent: Int32
    @NSManaged public var cardsStudied: Int32
    @NSManaged public var cardsRemaining: Int32
    @NSManaged public var quizzesCompleted: Int32
    @NSManaged public var averageScore: Double
    @NSManaged public var lastStudyDate: Date?
    @NSManaged public var studyStreak: Int32
    @NSManaged public var totalCards: Int32
    @NSManaged public var masteredCards: Int32
    
    func toModel() -> Progress {
        Progress(
            id: self.id,
            userId: self.userId,
            pdfFileId: self.pdfFileId,
            totalTimeSpent: Int(self.totalTimeSpent),
            cardsStudied: Int(self.cardsStudied),
            cardsRemaining: Int(self.cardsRemaining),
            quizzesCompleted: Int(self.quizzesCompleted),
            averageScore: self.averageScore,
            lastStudyDate: self.lastStudyDate,
            studyStreak: Int(self.studyStreak),
            totalCards: Int(self.totalCards),
            masteredCards: Int(self.masteredCards)
        )
    }
}
