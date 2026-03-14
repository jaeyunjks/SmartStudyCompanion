//
//  AsyncImageCache.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI
import Foundation

/// Image cache for async images to improve performance
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    /// Get cached image
    func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }
    
    /// Cache an image
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }
    
    /// Remove image from cache
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
    }
}

/// SwiftUI view for loading images asynchronously with caching
struct CachedAsyncImage<Content: View>: View {
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: NetworkError?
    
    let url: URL
    let content: (AsyncImagePhase) -> Content
    
    var body: some View {
        ZStack {
            switch (image, isLoading, error) {
            case (.some(let image), _, _):
                content(.success(Image(uiImage: image)))
            case (_, true, _):
                content(.empty)
            case (_, _, .some(let error)):
                content(.failure(error))
            default:
                content(.empty)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            if let uiImage = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.setImage(uiImage, forKey: cacheKey)
                self.image = uiImage
            }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.unknown(error)
        }
        isLoading = false
    }
}
