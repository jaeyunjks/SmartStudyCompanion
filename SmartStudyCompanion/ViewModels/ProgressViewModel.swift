//
//  ProgressViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for progress tracking operations
class ProgressViewModel: ObservableObject {
    @Published var progress: Progress?
    @Published var dailyStatistics: [DailyStatistics] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Fetch Progress
    
    /// Fetch progress for a PDF
    @MainActor
    func fetchProgress(for pdfFileId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedProgress = try await apiService.fetchProgress(for: pdfFileId)
            self.progress = fetchedProgress
            
            // Cache to CoreData
            try coreDataManager.saveProgress(fetchedProgress)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            // Try loading from cache
            if let cached = coreDataManager.fetchProgress(for: pdfFileId) {
                self.progress = cached
            }
        } catch {
            self.errorMessage = "Failed to fetch progress"
        }
        
        isLoading = false
    }
    
    //MARK: - load Progress
    
    @MainActor
    func loadProgress(for pdfField: String) async {
        await fetchProgress(for: pdfField)
    }
    
    // MARK: - Update Progress
    
    /// Update progress after studying
    @MainActor
    func updateProgress(pdfFileId: String, timeSpent: Int, cardsReviewed: Int, correctAnswers: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updated = try await apiService.updateProgress(
                pdfFileId: pdfFileId,
                timeSpent: timeSpent,
                cardsReviewed: cardsReviewed,
                correctAnswers: correctAnswers
            )
            
            self.progress = updated
            
            // Cache to CoreData
            try coreDataManager.saveProgress(updated)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to update progress"
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Statistics
    
    /// Fetch daily statistics for the past N days
    @MainActor
    func fetchDailyStatistics(days: Int = 7) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let stats = try await apiService.fetchDailyStatistics(days: days)
            self.dailyStatistics = stats
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to fetch statistics"
        }
        
        isLoading = false
    }
    
    // MARK: - Progress Helpers
    
    /// Get progress percentage
    var progressPercentage: Double {
        guard let progress = progress else { return 0 }
        let total = progress.totalCards > 0 ? progress.totalCards : 1
        return Double(progress.masteredCards) / Double(total) * 100
    }
    
    /// Get formatted time spent
    var formattedTimeSpent: String {
        guard let progress = progress else { return "0m" }
        let hours = progress.totalTimeSpent / 60
        let minutes = progress.totalTimeSpent % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
