//
//  MovieFlixApp.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct MovieFlixApp: App {
    var body: some Scene {
        WindowGroup {
//            MovieListView(
//                store: Store(
//                    initialState: MovieListFeature.State(),
//                    reducer: { MovieListFeature() }
//                )
//            )
            
            MovieListView()
        }
    }
}
