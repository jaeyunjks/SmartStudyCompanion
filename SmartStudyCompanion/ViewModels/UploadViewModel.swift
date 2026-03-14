//
//  UploadViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for PDF/Image upload operations
class UploadViewModel: ObservableObject {
    @Published var uploadedPDFs: [PDFFile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadProgress: Double = 0.0
    @Published var currentlyUploading: String?
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Upload PDF
    
    /// Upload a PDF file
    @MainActor
    func uploadPDF(fileName: String, fileData: Data) async {
        isLoading = true
        currentlyUploading = fileName
        errorMessage = nil
        
        do {
            let uploadedFile = try await apiService.uploadPDF(
                fileData: fileData,
                fileName: fileName,
                fileType: "pdf"
            )
            
            self.uploadedPDFs.append(uploadedFile)
            self.uploadProgress = 1.0
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to upload PDF"
        }
        
        isLoading = false
        currentlyUploading = nil
        uploadProgress = 0.0
    }
    
    /// Upload an image file
    @MainActor
    func uploadImage(fileName: String, imageData: Data) async {
        isLoading = true
        currentlyUploading = fileName
        errorMessage = nil
        
        do {
            let uploadedFile = try await apiService.uploadPDF(
                fileData: imageData,
                fileName: fileName,
                fileType: "image"
            )
            
            self.uploadedPDFs.append(uploadedFile)
            self.uploadProgress = 1.0
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to upload image"
        }
        
        isLoading = false
        currentlyUploading = nil
        uploadProgress = 0.0
    }
    
    // MARK: - Fetch PDFs
    
    /// Fetch list of user's uploaded PDFs
    @MainActor
    func fetchUserPDFs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let pdfs = try await apiService.fetchUserPDFs()
            self.uploadedPDFs = pdfs
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Failed to fetch PDFs"
        }
        
        isLoading = false
    }
}
