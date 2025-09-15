//
//  MovieDetailFeature.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

// MARK: - Movie Detail Feature
@Reducer
struct MovieDetailFeature {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var movie: Movie
        var detailedMovie: Movie?
        var isLoading = false
        var errorMessage: String?
        var isImageEditorPresented = false
        
        init(movie: Movie) {
            self.movie = movie
        }
    }
    
    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case fetchMovieDetails
        case movieDetailsResponse(Result<Movie, NetworkError>)
        case retry
        case imageEditorTapped
        case imageEditorDismissed
    }
    
    // MARK: - Dependencies
    @Dependency(\.movieService) var movieService
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear()
                
            case .fetchMovieDetails:
                return handleFetchMovieDetails(&state)
                
            case let .movieDetailsResponse(.success(detailedMovie)):
                return handleMovieDetailsSuccess(&state, movie: detailedMovie)
                
            case let .movieDetailsResponse(.failure(error)):
                return handleMovieDetailsFailure(&state, error: error)
                
            case .retry:
                return handleRetry()
                
            case .imageEditorTapped:
                return handleImageEditorTapped(&state)
                
            case .imageEditorDismissed:
                return handleImageEditorDismissed(&state)
            }
        }
    }
    
    // MARK: - Action Handlers
    private func handleOnAppear() -> Effect<Action> {
        return .send(.fetchMovieDetails)
    }
    
    private func handleFetchMovieDetails(_ state: inout State) -> Effect<Action> {
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
    }
    
    private func handleMovieDetailsSuccess(_ state: inout State, movie: Movie) -> Effect<Action> {
        state.isLoading = false
        state.detailedMovie = movie
        return .none
    }
    
    private func handleMovieDetailsFailure(_ state: inout State, error: NetworkError) -> Effect<Action> {
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
    }
    
    private func handleRetry() -> Effect<Action> {
        return .send(.fetchMovieDetails)
    }
    
    private func handleImageEditorTapped(_ state: inout State) -> Effect<Action> {
        state.isImageEditorPresented = true
        return .none
    }
    
    private func handleImageEditorDismissed(_ state: inout State) -> Effect<Action> {
        state.isImageEditorPresented = false
        return .none
    }
}

// MARK: - State Computed Properties
extension MovieDetailFeature.State {
    var displayMovie: Movie {
        detailedMovie ?? movie
    }
}
