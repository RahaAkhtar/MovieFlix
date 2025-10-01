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

    func configureKingfisher() {
        // 🔹 Disk + Memory cache
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 200 * 1024 * 1024  // 200 MB in memory
        cache.diskStorage.config.sizeLimit = 1 * 1024 * 1024 * 1024    // 1 GB on disk
        
        // 🔹 Set cache expiration
        cache.memoryStorage.config.expiration = .seconds(60 * 10) // 10 min in RAM
        cache.diskStorage.config.expiration = .days(7)            // 7 days on disk
        
        // 🔹 Downloader settings
        let downloader = KingfisherManager.shared.downloader
        downloader.downloadTimeout = 15 // per request timeout
        
        // 🔹 Global retry strategy
        KingfisherManager.shared.defaultOptions = [
            .transition(.fade(0.25)),
            .cacheOriginalImage,
            .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2)))
        ]
    }

    
    private func configureDependencies() {
        DependencyConfiguration.configure()
    }
}
