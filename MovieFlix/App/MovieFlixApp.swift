//
//  MovieFlixApp.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

@main
struct MovieFlixApp: App {
    
    init() {
        configureKingfisher()
        configureDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            MovieListView(
                store: Store(
                    initialState: MovieListFeature.State(),
                    reducer: { MovieListFeature() }
                )
            )
        }
    }
    
    private func configureKingfisher() {
        // Set up cache
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 500 // 500 MB
        
        // Set up downloader
        let downloader = ImageDownloader.default
        downloader.downloadTimeout = 30.0
    }
    
    private func configureDependencies() {
        DependencyConfiguration.configure()
    }
}
