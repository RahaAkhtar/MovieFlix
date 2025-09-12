//
//  MockMovieService.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public final class MockMovieService: MovieServiceProtocol {
    private let result: Result<[Movie], Error>

    public init(result: Result<[Movie], Error> = .success([])) {
        self.result = result
    }

    public func fetchMovies(page: Int) async throws -> [Movie] {
        switch result {
        case let .success(movies):
            return movies
        case let .failure(error):
            throw error
        }
    }
}
