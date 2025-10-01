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

        // Separate loading flags
        var isLoadingInitial: Bool = false   // first load / category load
        var isSearching: Bool = false        // inline search loading
        var isLoadingNextPage: Bool = false  // pagination
        var isRefreshing: Bool = false       // pull-to-refresh

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
    }

    enum Action: Equatable {
        case onAppear
        case fetchMovies                // initial/category/search fetch (uses state.currentPage)
        case loadNextPage               // pagination trigger
        case refresh                    // pull-to-refresh
        case moviesResponseSuccess([Movie], Int) // movies + page
        case moviesResponseFailure(NetworkError, Int)
        case selectCategory(String)
        case searchTextChanged(String)
        case sortOptionChanged(State.SortOption)
        case retry
        case movieTapped(Movie)
    }

    @Dependency(\.movieService) var movieService

    enum CancelID { case search }

    public init() {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchMovies)

            case .fetchMovies:
                return handleFetchMovies(&state)

            case let .moviesResponseSuccess(movies, page):
                return handleMoviesSuccess(&state, movies: movies, page: page)

            case let .moviesResponseFailure(error, page):
                return handleMoviesFailure(&state, error: error, page: page)

            case .loadNextPage:
                return handleLoadNextPage(&state)

            case let .selectCategory(category):
                return handleSelectCategory(&state, category: category)

            case let .searchTextChanged(text):
                return handleSearchTextChanged(&state, text: text)

            case let .sortOptionChanged(option):
                return handleSortOptionChanged(&state, option: option)

            case .retry:
                return handleRetry()

            case .refresh:
                return handleRefresh(&state)

            case .movieTapped:
                return .none
            }
        }
    }

    // MARK: - Handlers

    private func handleFetchMovies(_ state: inout State) -> Effect<Action> {
        // Prevent overlapping initial/search fetches
        guard !state.isLoadingInitial && !state.isSearching && !state.isRefreshing else {
            return .none
        }

        let isSearch = !state.searchText.isEmpty

        // set appropriate flag for UI
        if state.currentPage == 1 {
            if isSearch {
                state.isSearching = true
            } else {
                state.isLoadingInitial = true
            }
        } else {
            // should not usually happen; pagination uses loadNextPage handler
            state.isLoadingNextPage = true
        }

        state.errorMessage = nil
        let page = state.currentPage
        let query = isSearch ? state.searchText : state.selectedCategory

        return .run { send in
            do {
                let movies = try await movieService.fetchMovies(searchQuery: query, page: page)
                await send(.moviesResponseSuccess(movies, page))
            } catch {
                await send(.moviesResponseFailure(error as? NetworkError ?? .unknown, page))
            }
        }
    }

    private func handleLoadNextPage(_ state: inout State) -> Effect<Action> {
        // Only allow pagination when not searching and when not already loading
        guard state.hasMorePages &&
              !state.isLoadingNextPage &&
              !state.isLoadingInitial &&
              !state.isRefreshing &&
              !state.isSearching else {
            return .none
        }

        state.isLoadingNextPage = true
        state.errorMessage = nil
        let page = state.currentPage
        let query = state.searchText.isEmpty ? state.selectedCategory : state.searchText

        return .run { send in
            do {
                let movies = try await movieService.fetchMovies(searchQuery: query, page: page)
                await send(.moviesResponseSuccess(movies, page))
            } catch {
                await send(.moviesResponseFailure(error as? NetworkError ?? .unknown, page))
            }
        }
    }

    private func handleRefresh(_ state: inout State) -> Effect<Action> {
        guard !state.isRefreshing else { return .none }
        state.isRefreshing = true
        state.errorMessage = nil
        state.currentPage = 1
        state.hasMorePages = true

        let page = 1
        let query = state.searchText.isEmpty ? state.selectedCategory : state.searchText

        return .run { send in
            do {
                let movies = try await movieService.fetchMovies(searchQuery: query, page: page)
                await send(.moviesResponseSuccess(movies, page))
            } catch {
                await send(.moviesResponseFailure(error as? NetworkError ?? .unknown, page))
            }
        }
    }

    private func handleMoviesSuccess(_ state: inout State, movies: [Movie], page: Int) -> Effect<Action> {
        // reset loading flags relevant to this response
        if page == 1 {
            state.isLoadingInitial = false
            state.isRefreshing = false
            state.isSearching = false

            // replace the list on page 1 (initial / search / refresh)
            state.movies = movies
            state.currentPage = movies.isEmpty ? 1 : 2
        } else {
            state.isLoadingNextPage = false
            state.movies.append(contentsOf: movies)
            state.currentPage += 1
        }

        state.hasMorePages = !movies.isEmpty
        return .none
    }

    private func handleMoviesFailure(_ state: inout State, error: NetworkError, page: Int) -> Effect<Action> {
        if page == 1 {
            state.isLoadingInitial = false
            state.isRefreshing = false
            state.isSearching = false
            state.errorMessage = error.localizedDescription
        } else {
            state.isLoadingNextPage = false
            // for page > 1 you might show a toast; we still set an error message so UI can surface it if desired
            state.errorMessage = error.localizedDescription
        }
        return .none
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
        state.movies = []
        state.currentPage = 1
        state.hasMorePages = true

        // Debounce search input
        return .concatenate(
            .cancel(id: CancelID.search),
            .run { send in
                try await Task.sleep(nanoseconds: 400_000_000) // 0.4s
                await send(.fetchMovies)
            }
            .cancellable(id: CancelID.search)
        )
    }

    private func handleSortOptionChanged(_ state: inout State, option: State.SortOption) -> Effect<Action> {
        state.sortOption = option
        return .none
    }

    private func handleRetry() -> Effect<Action> {
        return .send(.fetchMovies)
    }
}

// MARK: - Computed (sorting)
extension MovieListFeature.State {
    var filteredMovies: [Movie] {
        // API provides search results; client-side filtering is removed (sorting remains)
        let filtered = movies
        switch sortOption {
        case .title:
            return sortByTitle(filtered)
        case .year:
            return sortByYear(filtered)
        case .rating:
            return sortByRating(filtered)
        }
    }

    private func sortByTitle(_ movies: [Movie]) -> [Movie] {
        movies.sorted { $0.title < $1.title }
    }

    private func sortByRating(_ movies: [Movie]) -> [Movie] {
        movies.sorted { $0.voteAverage > $1.voteAverage }
    }
    
    private func sortByYear(_ movies: [Movie]) -> [Movie] {
        movies.sorted { a, b in
            let y1 = YearParser.fastYear(from: a.releaseDate)
            let y2 = YearParser.fastYear(from: b.releaseDate)

            if y1 == y2 {
                return a.title < b.title // tiebreaker
            }
            return y1 > y2 // newest first
        }
    }

    private enum YearParser {
        private static let regex: NSRegularExpression = {
            try! NSRegularExpression(pattern: "\\b(19|20)\\d{2}\\b", options: [])
        }()

        static func fastYear(from raw: String?) -> Int {
            guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
                return 0
            }

            // Case 1: "1997"
            if raw.count == 4, let y = Int(raw), (1000...2999).contains(y) {
                return y
            }

            // Case 2: "1997-09-26"
            if raw.count >= 10, let y = Int(raw.prefix(4)), (1000...2999).contains(y) {
                return y
            }

            // Case 3: Regex fallback (e.g. "Released: 1997")
            let ns = raw as NSString
            if let match = regex.firstMatch(in: raw, range: NSRange(location: 0, length: ns.length)) {
                return Int(ns.substring(with: match.range)) ?? 0
            }

            return 0
        }
    }


}
