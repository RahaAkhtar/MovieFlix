//
//  MovieListFeatureTests.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import XCTest
import ComposableArchitecture

@testable import MovieFlix

// MARK: - MovieListFeature Tests
@MainActor
final class MovieListFeatureTests: XCTestCase {
    
    // MARK: - Test Properties
    private var store: TestStore<MovieListFeature.State, MovieListFeature.Action>!
    private var mockMovieService: MockMovieService!
    
    // MARK: - Test Data
       private let testMovies = [
           Movie(
               id: 1,
               title: "The Shawshank Redemption",
               overview: "Two imprisoned men bond over a number of years...",
               releaseDate: "1994-09-23",
               mediaType: "movie",
               voteAverage: 9.3,
               posterPath: "https://example.com/poster1.jpg",
               backdropPath: "https://example.com/backdrop1.jpg",
               staff: ["Frank Darabont", "Tim Robbins", "Morgan Freeman"],
               runtime: 142,
               budget: 25000000
           ),
           Movie(
               id: 2,
               title: "The Godfather",
               overview: "The aging patriarch of an organized crime dynasty...",
               releaseDate: "1972-03-24",
               mediaType: "movie",
               voteAverage: 9.2,
               posterPath: "https://example.com/poster2.jpg",
               backdropPath: "https://example.com/backdrop2.jpg",
               staff: ["Francis Ford Coppola", "Marlon Brando", "Al Pacino"],
               runtime: 175,
               budget: 6000000
           )
       ]
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        mockMovieService = MockMovieService()
        setupTestStore()
    }
    
    override func tearDown() {
        store = nil
        mockMovieService = nil
        super.tearDown()
    }
    
    private func setupTestStore() {
        store = TestStore(
            initialState: MovieListFeature.State(),
            reducer: { MovieListFeature() }
        ) {
            $0.movieService = mockMovieService
        }
    }
    
    // MARK: - OnAppear Tests
    func testOnAppearFetchesMovies() async {
        // Given
        mockMovieService.setMovies(testMovies)
        
        // When & Then
        await store.send(.onAppear)
        await store.receive(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.isLoading = false
            state.movies = self.testMovies
            state.currentPage = 2
            state.hasMorePages = true
        }
    }
    
    // MARK: - Fetch Movies Tests
    func testFetchMoviesSuccess() async {
        // Given
        mockMovieService.setMovies(testMovies)
        
        // When & Then
        await store.send(.fetchMovies) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.isLoading = false
            state.movies = self.testMovies
            state.currentPage = 2
            state.hasMorePages = true
        }
    }
    
    func testFetchMoviesFailure() async {
        // Given
        let expectedError = NetworkError.serverError(404, "Not Found")
        mockMovieService.setError(expectedError, for: "movies_action_1")
        
        // When & Then
        await store.send(.fetchMovies) { state in
            state.isLoading = true
            state.errorMessage = nil
        }
        
        await store.receive(.moviesResponse(.failure(expectedError))) { state in
            state.isLoading = false
            state.errorMessage = expectedError.localizedDescription
        }
    }
    
    func testFetchMoviesWhenAlreadyLoading() async {
        // Given
        store.exhaustivity = .off
        await store.send(.fetchMovies) { state in
            state.isLoading = true
        }
        
        // When & Then
        await store.send(.fetchMovies)
        // Should not receive any response since it's already loading
    }
    
    func testFetchMoviesWhenNoMorePages() async {
        // Given
        await store.send(.moviesResponse(.success([]))) { state in
            state.hasMorePages = false
        }
        
        // When & Then
        await store.send(.fetchMovies)
        // Should not receive any response since there are no more pages
    }
    
    // MARK: - Pagination Tests
    func testLoadNextPage() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
            state.currentPage = 1
        }
        
        // When & Then
        await store.send(.loadNextPage)
        await store.receive(.fetchMovies)
    }
    
    // MARK: - Category Selection Tests
    func testSelectCategory() async {
        // Given
        let newCategory = "comedy"
        mockMovieService.setMovies(testMovies)
        
        // When & Then
        await store.send(.selectCategory(newCategory)) { state in
            state.selectedCategory = newCategory
            state.movies = []
            state.currentPage = 1
            state.hasMorePages = true
        }
        
        await store.receive(.fetchMovies)
    }
    
    func testSelectSameCategoryDoesNothing() async {
        // Given
        let currentCategory = store.state.selectedCategory
        
        // When & Then
        await store.send(.selectCategory(currentCategory))
        // Should not receive fetchMovies action
    }
    
    // MARK: - Search Tests
    func testSearchTextChanged() async {
        // Given
        let searchText = "godfather"
        
        // When & Then
        await store.send(.searchTextChanged(searchText)) { state in
            state.searchText = searchText
        }
    }
    
    // MARK: - Sort Tests
    func testSortOptionChanged() async {
        // Given
        let newSortOption = MovieListFeature.State.SortOption.rating
        
        // When & Then
        await store.send(.sortOptionChanged(newSortOption)) { state in
            state.sortOption = newSortOption
        }
    }
    
    // MARK: - Retry Tests
    func testRetryAfterError() async {
        // Given
        let expectedError = NetworkError.serverError(404, "Not Found")
        mockMovieService.setError(expectedError, for: "movies_action_1")
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.failure(expectedError))) { state in
            state.errorMessage = expectedError.localizedDescription
        }
        
        // When & Then
        mockMovieService.setMovies(testMovies)
        await store.send(.retry)
        await store.receive(.fetchMovies)
    }
    
    // MARK: - Filtered Movies Tests
    func testFilteredMoviesWithSearch() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
        }
        
        await store.send(.searchTextChanged("godfather")) { state in
            state.searchText = "godfather"
        }
        
        // When
        let filteredMovies = store.state.filteredMovies
        
        // Then
        XCTAssertEqual(filteredMovies.count, 1)
        XCTAssertEqual(filteredMovies[0].title, "The Godfather")
    }
    
    func testFilteredMoviesSortByTitle() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
        }
        
        await store.send(.sortOptionChanged(.title)) { state in
            state.sortOption = .title
        }
        
        // When
        let sortedMovies = store.state.filteredMovies
        
        // Then
        XCTAssertEqual(sortedMovies[0].title, "The Godfather")
        XCTAssertEqual(sortedMovies[1].title, "The Shawshank Redemption")
    }
    
    func testFilteredMoviesSortByRating() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
        }
        
        await store.send(.sortOptionChanged(.rating)) { state in
            state.sortOption = .rating
        }
        
        // When
        let sortedMovies = store.state.filteredMovies
        
        // Then
        XCTAssertEqual(sortedMovies[0].title, "The Shawshank Redemption") // Higher rating
        XCTAssertEqual(sortedMovies[1].title, "The Godfather")
    }
    
    func testFilteredMoviesSortByYear() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
        }
        
        await store.send(.sortOptionChanged(.year)) { state in
            state.sortOption = .year
        }
        
        // When
        let sortedMovies = store.state.filteredMovies
        
        // Then
        XCTAssertEqual(sortedMovies[0].title, "The Shawshank Redemption") // Newer
        XCTAssertEqual(sortedMovies[1].title, "The Godfather") // Older
    }
    
    func testFilteredMoviesEmptySearch() async {
        // Given
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
        }
        
        // When
        let filteredMovies = store.state.filteredMovies
        
        // Then
        XCTAssertEqual(filteredMovies.count, 2)
    }
    
    // MARK: - Movie Tapped Tests
    func testMovieTapped() async {
        // Given
        let movie = testMovies[0]
        
        // When & Then
        await store.send(.movieTapped(movie))
        // Should handle navigation (tested in integration tests)
    }
    
    // MARK: - Edge Cases
    func testEmptyMoviesResponse() async {
        // Given
        mockMovieService.setMovies([])
        
        // When & Then
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success([]))) { state in
            state.isLoading = false
            state.movies = []
            state.currentPage = 2
            state.hasMorePages = false
        }
    }
}

// MARK: - Helper Methods for Complex State Setup
extension MovieListFeatureTests {
    private func setupStateWithMovies() async {
        mockMovieService.setMovies(testMovies)
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.success(testMovies))) { state in
            state.movies = self.testMovies
            state.currentPage = 2
            state.hasMorePages = true
            state.isLoading = false
        }
    }
    
    private func setupStateWithError() async {
        let expectedError = NetworkError.serverError(404, "Not Found")
        mockMovieService.setError(expectedError, for: "movies_action_1")
        await store.send(.fetchMovies)
        await store.receive(.moviesResponse(.failure(expectedError))) { state in
            state.isLoading = false
            state.errorMessage = expectedError.localizedDescription
        }
    }
}

// MARK: - Movie Service Tests
final class MovieServiceTests: XCTestCase {
    
    private var movieService: MovieService!
    private var mockHttpClient: MovieMockHTTPClient!
    
    override func setUp() {
        super.setUp()
        mockHttpClient = MovieMockHTTPClient()
        movieService = MovieService()
        // Use dependency injection or make httpClient internal for testing
        // For now, we'll test through the feature tests instead
    }
    
    override func tearDown() {
        movieService = nil
        mockHttpClient = nil
        super.tearDown()
    }
}

// MARK: - Mock HTTP Client for Service Tests
final class MovieMockHTTPClient: HTTPClient {
    var stubbedResponse: Any?
    var stubbedError: Error?
    
    func send<T>(_ request: Request<T>) async throws -> T where T : Decodable {
        if let error = stubbedError {
            throw error
        }
        
        guard let response = stubbedResponse as? T else {
            throw NetworkError.noData
        }
        
        return response
    }
}
