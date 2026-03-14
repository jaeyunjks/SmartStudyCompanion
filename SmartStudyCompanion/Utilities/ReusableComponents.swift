//
//  ReusableComponents.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

// MARK: - Flashcard View Component
struct FlashcardView: View {
    let flashcard: Flashcard
    @State private var isFlipped = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Card content
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondaryBackground)
                
                VStack(spacing: 16) {
                    Text(isFlipped ? "Answer" : "Question")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(isFlipped ? flashcard.back : flashcard.front)
                        .font(.headline)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 250)
            
            // Difficulty badge
            HStack {
                Badge(text: flashcard.difficulty.rawValue.capitalized, color: difficultyColor)
                Spacer()
                Text("Reviewed: \(flashcard.reviewCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(12)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var difficultyColor: Color {
        switch flashcard.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let summary: Summary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.title)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Label(summary.content.count.description, systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("\(summary.readingTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Content preview
            Text(summary.content)
                .font(.caption)
                .lineLimit(3)
                .foregroundColor(.gray)
            
            // Key points
            if !summary.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Points")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(summary.keyPoints.prefix(3), id: \.self) { point in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 4, height: 4)
                            
                            Text(point)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Progress Bar Component
struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                
                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(width: progress * geometry.size.width)
            }
            .frame(height: height)
        }
        .frame(height: height)
    }
    
    private var progressColor: Color {
        if progress < 0.33 {
            return .red
        } else if progress < 0.67 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Badge Component
struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

// MARK: - Empty State Component
struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionText: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let actionText = actionText, let action = action {
                Button(action: action) {
                    Text(actionText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        FlashcardView(flashcard: Flashcard(
            id: "1",
            userId: "user1",
            pdfFileId: "pdf1",
            setId: nil,
            front: "What is SwiftUI?",
            back: "A modern UI framework for Apple platforms",
            difficulty: .medium,
            createdAt: Date(),
            lastReviewedAt: nil,
            reviewCount: 5,
            correctCount: 3
        ))
        
        ProgressBar(progress: 0.65)
        
        Badge(text: "Medium", color: .orange)
    }
    .padding()
}
