//
//  MovieServiceTests.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


//import XCTest
//@testable import MovieFlix
//
//final class MovieServiceTests: XCTestCase {
//    
//    func testFetchMoviesSuccess() async throws {
//        let mock = MockMovieService()
//        mock.moviesToReturn = [ 
//            Movie(id: 1, title: "Inception", overview: "Dream heist.", releaseDate: "2010-07-16", mediaType: "movie", voteAverage: 8.8, posterPath: "/poster.jpg", backdropPath: "/backdrop.jpg")
//        ]
//        
//        let movies = try await mock.fetchMovies(page: 1)
//        XCTAssertEqual(movies.count, 1)
//        XCTAssertEqual(movies.first?.title, "Inception")
//    }
//    
//    func testFetchMoviesFailure() async {
//        let mock = MockMovieService()
//        mock.errorToThrow = NetworkError.httpError(code: 500)
//        
//        do {
//            _ = try await mock.fetchMovies(page: 1)
//            XCTFail("Expected error not thrown")
//        } catch let error as NetworkError {
//            XCTAssertEqual(error, .httpError(code: 500))
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
//}
