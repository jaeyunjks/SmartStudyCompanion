//
//  SummaryViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for summary operations (generate, fetch, cache)
class SummaryViewModel: ObservableObject {
    @Published var summary: Summary?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Generate Summary
    
    /// Generate an AI summary for a PDF
    @MainActor
    func generateSummary(pdfFileId: String, length: SummaryRequest.SummaryLength) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let generatedSummary = try await apiService.fetchSummary(
                pdfFileId: pdfFileId,
                summaryLength: length
            )
            
            self.summary = generatedSummary
            
            // Cache to CoreData
            try coreDataManager.saveSummary(generatedSummary)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            // Try to load from cache if network fails
            loadSummaryFromCache(pdfFileId: pdfFileId)
        } catch {
            self.errorMessage = "Failed to generate summary"
            loadSummaryFromCache(pdfFileId: pdfFileId)
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Summary
    
    /// Fetch existing summary from server
    @MainActor
    func fetchSummary(pdfFileId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let fetchedSummary = try await apiService.getSummary(for: pdfFileId) {
                self.summary = fetchedSummary
                try coreDataManager.saveSummary(fetchedSummary)
            } else {
                loadSummaryFromCache(pdfFileId: pdfFileId)
            }
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            loadSummaryFromCache(pdfFileId: pdfFileId)
        } catch {
            self.errorMessage = "Failed to fetch summary"
            loadSummaryFromCache(pdfFileId: pdfFileId)
        }
        
        isLoading = false
    }
    
    // MARK: - Cache Operations
    
    /// Load summary from CoreData cache
    private func loadSummaryFromCache(pdfFileId: String) {
        if let cachedSummary = coreDataManager.fetchSummary(pdfFileId: pdfFileId) {
            self.summary = cachedSummary
        }
    }
}
