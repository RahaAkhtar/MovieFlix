//
//  BackgroundView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 01/10/2025.
//

import SwiftUI
import Kingfisher

struct BackgroundView: View {
    let backdropURL: URL?
    let posterURL: URL?
    let geometry: GeometryProxy
    let processedImage: UIImage?
    
    var body: some View {
        Color.clear
            .background(
                Group {
                    if let processedImage = processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                            .blur(radius: 20)
                            .opacity(0.3)
                    } else {
                        RetryableKFImage(
                            url: backdropURL,
                            fallbackURL: posterURL,
                            imageContentMode: .fill,
                            blur: 20,
                            frame: CGSize(width: geometry.size.width,
                                        height: geometry.safeAreaInsets.top + 100)
                        )
                        .opacity(0.3)
                    }
                }
            )
            .frame(height: geometry.safeAreaInsets.top + 100)
            .ignoresSafeArea()
    }
}
