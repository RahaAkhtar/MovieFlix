//
//  MovieServiceKey.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import ComposableArchitecture

private enum MovieServiceKey: DependencyKey {
    static let liveValue: MovieServiceProtocol = MovieService(client: URLSessionHTTPClient())
    static var testValue: MovieServiceProtocol {
        MockMovieService(result: .success([
            Movie(id: 1,
                  title: "Mock Movie",
                  overview: "Overview",
                  releaseDate: "2024-01-01",
                  mediaType: "movie",
                  voteAverage: 7.5,
                  posterPath: nil,
                  backdropPath: nil,
                  staff: [],
                  runtime: 10,
                  budget: 20.0
                 )
        ]))
    }
}


extension DependencyValues {
    var movieService: MovieServiceProtocol {
        get { self[MovieServiceKey.self] }
        set { self[MovieServiceKey.self] = newValue }
    }
}
