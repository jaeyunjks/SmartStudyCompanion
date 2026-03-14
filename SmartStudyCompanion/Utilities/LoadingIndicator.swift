//
//  LoadingIndicator.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

/// Reusable loading indicator component
struct LoadingIndicator: View {
    var size: CGFloat = 50
    var color: Color = .blue
    
    var body: some View {
        ProgressView()
            .scaleEffect(size / 50)
            .tint(color)
    }
}

/// Overlay loading view
struct LoadingOverlay: View {
    var isLoading: Bool
    var message: String = "Loading..."
    
    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(12)
            }
        }
    }
}

/// Error message banner
struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.caption)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingIndicator()
        LoadingOverlay(isLoading: true, message: "Processing...")
        ErrorBanner(message: "An error occurred while loading data") {}
    }
    .padding()
}
