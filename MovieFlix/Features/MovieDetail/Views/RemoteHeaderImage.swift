//
//  RemoteHeaderImage.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct RemoteHeaderImage: View {
    let url: URL?
    let scrollOffset: CGFloat
    let geometry: GeometryProxy
    let headerHeight: CGFloat
    
    var body: some View {
        RemoteImageView(url: url)
            .frame(width: geometry.size.width, height: headerHeight)
            .clipped()
            .offset(y: scrollOffset * 0.3)
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

struct RemoteBlurBackground: View {
    let url: URL?
    let geometry: GeometryProxy
    
    var body: some View {
        RemoteImageView(url: url)
            .frame(width: geometry.size.width)
            .blur(radius: 20)
            .opacity(0.3)
            .ignoresSafeArea()
    }
}
