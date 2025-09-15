//
//  MovieListFeature.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

// MARK: - Movie List Feature
@Reducer
struct MovieListFeature {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var movies: [Movie] = []
        var isLoading = false
        var errorMessage: String?
        var hasMorePages = true
        var selectedCategory: String = "action"
        var searchText = ""
        var sortOption: SortOption = .title
        var currentPage = 1
        
        // MARK: - Sort Options
        enum SortOption: String, CaseIterable, Equatable {
            case title = "Title"
            case year = "Year"
            case rating = "Rating"
        }
        
        // MARK: - Initialization
        public init() {}
        
        // MARK: - Test Initializer
        public init(
            movies: [Movie] = [],
            isLoading: Bool = false,
            errorMessage: String? = nil,
            hasMorePages: Bool = true,
            selectedCategory: String = "action",
            searchText: String = "",
            sortOption: SortOption = .title,
            currentPage: Int = 1
        ) {
            self.movies = movies
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.hasMorePages = hasMorePages
            self.selectedCategory = selectedCategory
            self.searchText = searchText
            self.sortOption = sortOption
            self.currentPage = currentPage
        }
    }
    
    // MARK: - Action
    enum Action: Equatable {
        case onAppear
        case fetchMovies
        case moviesResponse(Result<[Movie], NetworkError>)
        case loadNextPage
        case selectCategory(String)
        case searchTextChanged(String)
        case sortOptionChanged(State.SortOption)
        case retry
        case movieTapped(Movie)
    }
    
    // MARK: - Dependencies
    @Dependency(\.movieService) var movieService
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear()
                
            case .fetchMovies:
                return handleFetchMovies(&state)
                
            case let .moviesResponse(.success(movies)):
                return handleMoviesSuccess(&state, movies: movies)
                
            case let .moviesResponse(.failure(error)):
                return handleMoviesFailure(&state, error: error)
                
            case .loadNextPage:
                return handleLoadNextPage()
                
            case let .selectCategory(category):
                return handleSelectCategory(&state, category: category)
                
            case let .searchTextChanged(text):
                return handleSearchTextChanged(&state, text: text)
                
            case let .sortOptionChanged(option):
                return handleSortOptionChanged(&state, option: option)
                
            case .retry:
                return handleRetry()
                
            case .movieTapped:
                return handleMovieTapped()
            }
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleOnAppear() -> Effect<Action> {
        return .send(.fetchMovies)
    }
    
    private func handleFetchMovies(_ state: inout State) -> Effect<Action> {
        guard !state.isLoading && state.hasMorePages else {
            return .none
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { [category = state.selectedCategory, page = state.currentPage] send in
            do {
                let movies = try await movieService.fetchMovies(searchQuery: category, page: page)
                await send(.moviesResponse(.success(movies)))
            } catch {
                await send(.moviesResponse(.failure(error as? NetworkError ?? NetworkError.unknown)))
            }
        }
    }
    
    private func handleMoviesSuccess(_ state: inout State, movies: [Movie]) -> Effect<Action> {
        state.isLoading = false
        state.movies.append(contentsOf: movies)
        state.currentPage += 1
        state.hasMorePages = !movies.isEmpty
        return .none
    }
    
    private func handleMoviesFailure(_ state: inout State, error: NetworkError) -> Effect<Action> {
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
    }
    
    private func handleLoadNextPage() -> Effect<Action> {
        return .send(.fetchMovies)
    }
    
    private func handleSelectCategory(_ state: inout State, category: String) -> Effect<Action> {
        guard category != state.selectedCategory else {
            return .none
        }
        
        state.selectedCategory = category
        state.movies = []
        state.currentPage = 1
        state.hasMorePages = true
        return .send(.fetchMovies)
    }
    
    private func handleSearchTextChanged(_ state: inout State, text: String) -> Effect<Action> {
        state.searchText = text
        return .none
    }
    
    private func handleSortOptionChanged(_ state: inout State, option: State.SortOption) -> Effect<Action> {
        state.sortOption = option
        return .none
    }
    
    private func handleRetry() -> Effect<Action> {
        return .send(.fetchMovies)
    }
    
    private func handleMovieTapped() -> Effect<Action> {
        return .none
    }
}

// MARK: - State Computed Properties
extension MovieListFeature.State {
    var filteredMovies: [Movie] {
        let filtered = searchText.isEmpty ? movies : movies.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .title:
            return sortByTitle(filtered)
        case .year:
            return sortByYear(filtered)
        case .rating:
            return sortByRating(filtered)
        }
    }
    
    // MARK: - Sorting Methods
    
    private func sortByTitle(_ movies: [Movie]) -> [Movie] {
        movies.sorted { $0.title < $1.title }
    }
    
    private func sortByYear(_ movies: [Movie]) -> [Movie] {
        movies.sorted {
            let year1 = Int($0.releaseDate ?? "") ?? 0
            let year2 = Int($1.releaseDate ?? "") ?? 0
            return year1 > year2
        }
    }
    
    private func sortByRating(_ movies: [Movie]) -> [Movie] {
        movies.sorted { $0.voteAverage > $1.voteAverage }
    }
}
