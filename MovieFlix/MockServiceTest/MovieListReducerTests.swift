//
//  MovieListReducerTests.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


//import XCTest
//import ComposableArchitecture
//@testable import MovieFlix
//
//final class MovieListReducerTests: XCTestCase {
//    func testOnAppearLoadsMovies() async {
//        let mock = MockMovieService()
//        mock.moviesToReturn = [Movie(id: 1, title: "A", overview: "", releaseDate: "2020-01-01", mediaType: "movie", voteAverage: 7.0, posterPath: nil, backdropPath: nil)]
//
//        let store = TestStore(
//            initialState: MovieListState(),
//            reducer: movieListReducer,
//            environment: MovieListEnvironment(mainQueue: .immediate, movieService: mock)
//        )
//
//        await store.send(.onAppear)
//        await store.receive(.moviesResponse(.success(mock.moviesToReturn))) { state in
//            state.movies = mock.moviesToReturn
//            state.isLoading = false
//        }
//    }
//
//    func testLoadNextPageAppends() async {
//        let mock = MockMovieService()
//        mock.moviesToReturn = [Movie(id: 2, title: "B", overview: "", releaseDate: "2021-01-01", mediaType: "movie", voteAverage: 6.5, posterPath: nil, backdropPath: nil)]
//
//        var initial = MovieListState()
//        initial.movies = [Movie(id: 1, title: "A", overview: "", releaseDate: "2020-01-01", mediaType: "movie", voteAverage: 7.0, posterPath: nil, backdropPath: nil)]
//
//        let store = TestStore(
//            initialState: initial,
//            reducer: movieListReducer,
//            environment: MovieListEnvironment(mainQueue: .immediate, movieService: mock)
//        )
//
//        await store.send(.loadNextPage)
//        await store.receive(.moviesResponse(.success(mock.moviesToReturn))) { state in
//            state.movies.append(contentsOf: mock.moviesToReturn)
//            state.isLoading = false
//            state.page = 2
//        }
//    }
//
//    func testFailureRevertsPageAndSetsError() async {
//        let mock = MockMovieService()
//        mock.errorToThrow = NetworkError.httpError(code: 500)
//
//        var initial = MovieListState()
//        initial.page = 1
//
//        let store = TestStore(
//            initialState: initial,
//            reducer: movieListReducer,
//            environment: MovieListEnvironment(mainQueue: .immediate, movieService: mock)
//        )
//
//        await store.send(.loadNextPage)
//        await store.receive(.moviesResponse(.failure(NetworkError.httpError(code: 500)))) { state in
//            state.isLoading = false
//            state.page = 1
//            XCTAssertNotNil(state.errorMessage)
//        }
//    }
//}
