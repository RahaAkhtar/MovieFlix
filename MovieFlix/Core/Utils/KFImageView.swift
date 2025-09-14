//
//  KFImageView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Kingfisher
import SwiftUI
import Foundation

// MARK: - Kingfisher Image Views
// Typealias for clarity
typealias ImageContentMode = SwiftUI.ContentMode

struct KFImageView: View {
    let url: URL?
    let placeholder: Image
    let contentMode: ImageContentMode
    let width: CGFloat?
    let height: CGFloat?
    
    init(
        url: URL?,
        placeholder: Image = Image(systemName: "film"),
        contentMode: ImageContentMode = .fill,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.width = width
        self.height = height
    }
    
    var body: some View {
        KFImage(url)
            .placeholder {
                placeholder
                    .foregroundColor(.gray)
                    .font(.title2)
            }
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: width, height: height)
            .clipped()
    }
}

// MARK: - Pre-configured styles for different use cases

// Movie Poster Style
struct KFPosterImage: View {
    let url: URL?
    let cornerRadius: CGFloat
    
    init(url: URL?, cornerRadius: CGFloat = 8) {
        self.url = url
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        KFImageView(
            url: url,
            placeholder: Image(systemName: "film.fill"),
            contentMode: .fill,
            width: 60,
            height: 90
        )
        .cornerRadius(cornerRadius)
    }
}

// Movie Backdrop Style (for headers)
struct KFBackdropImage: View {
    let url: URL?
    let height: CGFloat
    
    init(url: URL?, height: CGFloat = 200) {
        self.url = url
        self.height = height
    }
    
    var body: some View {
        KFImageView(
            url: url,
            placeholder: Image(systemName: "photo.on.rectangle"),
            contentMode: .fill
        )
        .frame(height: height)
        .clipped()
    }
}

// Circular Avatar Style
struct KFAvatarImage: View {
    let url: URL?
    let size: CGFloat
    
    init(url: URL?, size: CGFloat = 50) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        KFImageView(
            url: url,
            placeholder: Image(systemName: "person.circle.fill"),
            contentMode: .fill,
            width: size,
            height: size
        )
        .clipShape(Circle())
    }
}

// Grid Item Style
struct KFGridImage: View {
    let url: URL?
    let aspectRatio: CGFloat
    
    init(url: URL?, aspectRatio: CGFloat = 0.67) { // 2:3 aspect ratio
        self.url = url
        self.aspectRatio = aspectRatio
    }
    
    var body: some View {
        KFImageView(
            url: url,
            placeholder: Image(systemName: "film"),
            contentMode: .fill
        )
        .aspectRatio(aspectRatio, contentMode: .fit)
        .cornerRadius(8)
    }
}
