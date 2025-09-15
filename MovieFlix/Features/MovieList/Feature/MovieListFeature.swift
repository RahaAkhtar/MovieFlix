//
//  MovieListFeature.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

@Reducer
struct MovieListFeature {
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
        
        enum SortOption: String, CaseIterable, Equatable {
            case title = "Title"
            case year = "Year"
            case rating = "Rating"
        }
        
        public init() {}
        
        // Custom initializers for testing
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
    
    @Dependency(\.movieService) var movieService
    
    public init() {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchMovies)
                
            case .fetchMovies:
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
                
            case let .moviesResponse(.success(movies)):
                state.isLoading = false
                state.movies.append(contentsOf: movies)
                state.currentPage += 1
                state.hasMorePages = !movies.isEmpty
                return .none
                
            case let .moviesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .loadNextPage:
                return .send(.fetchMovies)
                
            case let .selectCategory(category):
                guard category != state.selectedCategory else {
                    return .none
                }
                
                state.selectedCategory = category
                state.movies = []
                state.currentPage = 1
                state.hasMorePages = true
                return .send(.fetchMovies)
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case let .sortOptionChanged(option):
                state.sortOption = option
                return .none
                
            case .retry:
                return .send(.fetchMovies)
                
            case .movieTapped:
                return .none
            }
        }
    }
}

// MARK: - Computed Properties
extension MovieListFeature.State {
    var filteredMovies: [Movie] {
        let filtered = searchText.isEmpty ? movies : movies.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .title:
            return filtered.sorted { $0.title < $1.title }
        case .year:
            return filtered.sorted {
                let year1 = Int($0.releaseDate ?? "") ?? 0
                let year2 = Int($1.releaseDate ?? "") ?? 0
                return year1 > year2
            }
        case .rating:
            return filtered.sorted { $0.voteAverage > $1.voteAverage }
        }
    }
}
