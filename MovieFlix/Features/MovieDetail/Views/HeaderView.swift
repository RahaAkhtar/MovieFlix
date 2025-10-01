//
//  HeaderView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 01/10/2025.
//

import Kingfisher
import SwiftUI

struct HeaderView: View {
    let movie: Movie
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    let geometry: GeometryProxy
    let processedImage: UIImage?
    @State private var imageLoadFailed = false
    
    var body: some View {
            ZStack(alignment: .bottomLeading) {
                if let processedImage = processedImage {
                    Image(uiImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: headerHeight)
                        .clipped()
                        .offset(y: scrollOffset * 0.2)
                        .overlay(gradientOverlay)
                } else {
                    RetryableKFImage(
                        url: movie.backdropURL,
                        fallbackURL: movie.posterURL,
                        imageContentMode: .fill,
                        blur: 0,
                        frame: CGSize(width: geometry.size.width, height: headerHeight)
                    )
                    .clipped()
                    .offset(y: scrollOffset * 0.2)
                    .overlay(gradientOverlay)
                }
                
                movieInfoOverlay
            }
        }
    
    private func logBrokenURL(_ url: URL?) {
        if let url = url {
            print("🖼️ Failed to load image from URL: \(url.absoluteString)")
        } else {
            print("🖼️ No image URL provided")
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(colors: [.clear, .black.opacity(0.7)],
                       startPoint: .top, endPoint: .bottom)
    }
    
    private var movieInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(movie.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 20) {
                InfoBadgeView.rating(movie.voteAverage)
                InfoBadgeView.year(movie.releaseDate ?? "Unknown")
                InfoBadgeView.mediaType(movie.mediaType)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}
