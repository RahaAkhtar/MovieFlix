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
        RetryableKFImage(
            url: url,
            fallbackURL: nil,
            imageContentMode: .fill,
            blur: 0,
            frame: CGSize(width: 120, height: 180)
        )
        .clipped()
        .cornerRadius(8)
        .shadow(radius: 2)
//        KFImageView(
//            url: url,
//            placeholder: Image(systemName: "film.fill"),
//            contentMode: .fill,
//            width: 60,
//            height: 90
//        )
//        .cornerRadius(cornerRadius)
    }
}

