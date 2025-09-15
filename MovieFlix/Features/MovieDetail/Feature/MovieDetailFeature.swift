//
//  MovieDetailFeature.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

@Reducer
public struct MovieDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var movie: Movie
        public var detailedMovie: Movie?
        public var isLoading = false
        public var errorMessage: String?
        public var isImageEditorPresented = false
        
        public init(movie: Movie) {
            self.movie = movie
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case fetchMovieDetails
        case movieDetailsResponse(Result<Movie, NetworkError>)
        case retry
        case imageEditorTapped
        case imageEditorDismissed
    }
    
    @Dependency(\.movieService) var movieService
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchMovieDetails)
                
            case .fetchMovieDetails:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [imdbID = state.movie.imdbID] send in
                    do {
                        let detailedMovie = try await movieService.fetchMovieDetails(imdbID: String(imdbID))
                        await send(.movieDetailsResponse(.success(detailedMovie)))
                    } catch {
                        await send(.movieDetailsResponse(.failure(error as? NetworkError ?? NetworkError.unknown)))
                    }
                }
                
            case let .movieDetailsResponse(.success(detailedMovie)):
                state.isLoading = false
                state.detailedMovie = detailedMovie
                return .none
                
            case let .movieDetailsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .retry:
                return .send(.fetchMovieDetails)
                
            case .imageEditorTapped:
                state.isImageEditorPresented = true
                return .none
                
            case .imageEditorDismissed:
                state.isImageEditorPresented = false
                return .none
            }
        }
    }
}

// MARK: - Computed Properties
extension MovieDetailFeature.State {
    public var displayMovie: Movie {
        detailedMovie ?? movie
    }
}
