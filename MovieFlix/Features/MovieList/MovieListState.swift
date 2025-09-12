//
//  MovieListState.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation
import ComposableArchitecture

public struct MovieListFeature: Reducer {
    public struct State: Equatable {
        public var movies: [Movie] = []
        public var isLoading: Bool = false
        public var page: Int = 1
        public var errorMessage: String? = nil

        public init(
            movies: [Movie] = [],
            isLoading: Bool = false,
            page: Int = 1,
            errorMessage: String? = nil
        ) {
            self.movies = movies
            self.isLoading = isLoading
            self.page = page
            self.errorMessage = errorMessage
        }
    }

    public enum Action: Equatable {
        case onAppear
        case refresh
        case loadNextPage
        case moviesResponseSuccess([Movie])
        case moviesResponseFailure(String)
        case movieTapped(id: Int)
    }

    @Dependency(\.movieService) var movieService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.movies.isEmpty else { return .none }
                state.isLoading = true
                state.page = 1
                state.errorMessage = nil
                let page = state.page
                return .run { send in
                    do {
                        let movies = try await movieService.fetchMovies(page: page)
                        await send(.moviesResponseSuccess(movies))
                    } catch {
                        await send(.moviesResponseFailure(error.localizedDescription))
                    }
                }

            case .refresh:
                state.isLoading = true
                state.page = 1
                state.errorMessage = nil
                let page = state.page
                return .run { send in
                    do {
                        let movies = try await movieService.fetchMovies(page: page)
                        await send(.moviesResponseSuccess(movies))
                    } catch {
                        await send(.moviesResponseFailure(error.localizedDescription))
                    }
                }

            case .loadNextPage:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                state.page += 1
                let page = state.page
                return .run { send in
                    do {
                        let movies = try await movieService.fetchMovies(page: page)
                        await send(.moviesResponseSuccess(movies))
                    } catch {
                        await send(.moviesResponseFailure(error.localizedDescription))
                    }
                }

            case .moviesResponseSuccess(let movies):
                state.isLoading = false
                if state.page == 1 {
                    state.movies = movies
                } else {
                    state.movies += movies
                }
                state.errorMessage = nil
                return .none

            case .moviesResponseFailure(let message):
                state.isLoading = false
                state.page = max(1, state.page - 1)
                state.errorMessage = message
                return .none

            case .movieTapped:
                return .none
            }
        }
    }
}

