////
////  MovieListFeatureTests.swift
////  MovieFlix
////
////  Created by Muhammad Akhtar on 10/09/2025.
////
//
//import XCTest
//import ComposableArchitecture
//
//@MainActor
//final class MovieListFeatureTests: XCTestCase {
//    
//    func testOnAppearFetchesMovies() async {
//        let store = TestStore(
//            initialState: MovieListFeature.State(),
//            reducer: { MovieListFeature() }
//        ) {
//            $0.movieService = MockMovieService()
//        }
//        
//        await store.send(.onAppear) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(.fetchMovies) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(.moviesResponse(.success([]))) {
//            $0.isLoading = false
//            $0.movies = []
//            $0.currentPage = 2
//            $0.hasMorePages = false
//        }
//    }
//    
//    func testSelectCategoryResetsStateAndFetchesMovies() async {
//        let store = TestStore(
//            initialState: MovieListFeature.State(
//                movies: [Movie(id: 1, title: "Test", overview: nil, releaseDate: nil, mediaType: "Movie", voteAverage: 8.0, posterPath: nil, backdropPath: nil, staff: nil, runtime: nil, budget: nil)],
//                selectedCategory: "action"
//            ),
//            reducer: { MovieListFeature() }
//        ) {
//            $0.movieService = MockMovieService()
//        }
//        
//        await store.send(.selectCategory("comedy")) {
//            $0.selectedCategory = "comedy"
//            $0.movies = []
//            $0.currentPage = 1
//            $0.hasMorePages = true
//        }
//        
//        await store.receive(.fetchMovies) {
//            $0.isLoading = true
//        }
//    }
//    
//    func testSearchTextChanged() async {
//        let store = TestStore(
//            initialState: MovieListFeature.State(),
//            reducer: { MovieListFeature() }
//        )
//        
//        await store.send(.searchTextChanged("test")) {
//            $0.searchText = "test"
//        }
//    }
//    
//    func testSortOptionChanged() async {
//        let store = TestStore(
//            initialState: MovieListFeature.State(),
//            reducer: { MovieListFeature() }
//        )
//        
//        await store.send(.sortOptionChanged(.year)) {
//            $0.sortOption = .year
//        }
//    }
//    
//    func testRetryAfterError() async {
//        let mockService = MockMovieService()
//        mockService.setError(NetworkError.networkError("Test error"), for: "movies_action_1")
//        
//        let store = TestStore(
//            initialState: MovieListFeature.State(),
//            reducer: { MovieListFeature() }
//        ) {
//            $0.movieService = mockService
//        }
//        
//        await store.send(.fetchMovies) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(.moviesResponse(.failure(NetworkError.networkError("Test error")))) {
//            $0.isLoading = false
//            $0.errorMessage = "Network error: Test error"
//        }
//        
//        await store.send(.retry) {
//            $0.isLoading = true
//            $0.errorMessage = nil
//        }
//    }
//}
