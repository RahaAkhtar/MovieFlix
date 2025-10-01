//
//  RetryableKFImage.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 01/10/2025.
//


import SwiftUI
import Kingfisher

struct RetryableKFImage: View {
    let url: URL?
    let fallbackURL: URL?
    let imageContentMode: SwiftUI.ContentMode
    let blur: CGFloat
    let frame: CGSize?
    
    @State private var reloadToken = UUID()
    @State private var primaryLoadFailed = false
    @State private var fallbackLoadFailed = false
    @State private var isLoading = true
    
    private var displayURL: URL? {
        if !primaryLoadFailed && url != nil {
            return url
        } else if !fallbackLoadFailed && fallbackURL != nil {
            return fallbackURL
        }
        return nil
    }
    
    private var allLoadFailed: Bool {
        (url == nil || primaryLoadFailed) && (fallbackURL == nil || fallbackLoadFailed)
    }
    
    var body: some View {
        ZStack {
            if let displayURL = displayURL {
                KFImage.url(displayURL)
                    .placeholder {
                        if isLoading {
                            Color.gray.opacity(0.2).overlay(ProgressView())
                        } else {
                            Color.black.opacity(0.4)
                        }
                    }
                    .onFailure { _ in
                        isLoading = false
                        if displayURL == url {
                            primaryLoadFailed = true
                            logBrokenURL(url, type: "Primary")
                        } else {
                            fallbackLoadFailed = true
                            logBrokenURL(fallbackURL, type: "Fallback")
                        }
                    }
                    .onSuccess { _ in
                        isLoading = false
                        primaryLoadFailed = false
                        fallbackLoadFailed = false
                    }
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: imageContentMode)
                    .ifLet(frame) { view, size in
                        view.frame(width: size.width, height: size.height)
                    }
                    .blur(radius: blur)
                    .id(reloadToken)
            } else {
                // Show error state when no URLs available or all failed
                errorStateView
            }
            
            // Retry button - show when all images failed or no URLs available
            if allLoadFailed {
                retryButtonView
            }
        }
        .onAppear {
            // Check if we have any valid URLs to load
            if url == nil && fallbackURL == nil {
                isLoading = false
            }
        }
    }
    
    private var errorStateView: some View {
        ZStack {
            Color.black.opacity(0.4)
            
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(getErrorMessage())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    private var retryButtonView: some View {
        VStack {
            Spacer()
            
            Button("Retry Image") {
                retryLoading()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Spacer()
        }
    }
    
    private func getErrorMessage() -> String {
        if url == nil && fallbackURL == nil {
            return "No image available"
        } else if allLoadFailed {
            return "Failed to load image"
        } else {
            return "Loading..."
        }
    }
    
    private func retryLoading() {
        isLoading = true
        primaryLoadFailed = false
        fallbackLoadFailed = false
        reloadToken = UUID()
    }
    
    private func logBrokenURL(_ url: URL?, type: String) {
        if let url = url {
            print("🖼️ [\(type)] Failed to load image: \(url.absoluteString)")
        } else {
            print("🖼️ [\(type)] No image URL provided")
        }
    }
}

// Helper view modifier for optional frame
extension View {
    @ViewBuilder
    func ifLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}
