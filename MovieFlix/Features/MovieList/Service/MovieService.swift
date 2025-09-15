//
//  MovieService.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Foundation
import Dependencies
import ComposableArchitecture

// MARK: - Movie Service Protocol
protocol MovieServiceProtocol {
    func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie]
    func fetchMovieDetails(imdbID: String) async throws -> Movie
}

// MARK: - Movie Service Implementation
final class MovieService: MovieServiceProtocol {
    
    // MARK: - Dependencies
    @Dependency(\.httpClient) private var httpClient
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie] {
        guard let url = APIUrls.movieListURL(searchQuery: searchQuery, page: page) else {
            throw NetworkError.invalidURL
        }
        
        let request = Request<OMDbSearchResponse>(url: url)
        let response = try await httpClient.send(request)
        
        return try processMoviesResponse(response)
    }
    
    func fetchMovieDetails(imdbID: String) async throws -> Movie {
        guard let url = APIUrls.movieDetailURL(imdbID: imdbID) else {
            throw NetworkError.invalidURL
        }
        
        let request = Request<OMDbMovieDetail>(url: url)
        let response = try await httpClient.send(request)
        
        return response.toMovie()
    }
    
    // MARK: - Private Methods
    
    private func processMoviesResponse(_ response: OMDbSearchResponse) throws -> [Movie] {
        // Check if the API returned an error
        if response.response.lowercased() == "false", let errorMessage = response.error {
            throw NetworkError.serverError(400, errorMessage)
        }
        
        return response.movies.map { $0.toMovie() }
    }
}

// MARK: - Dependency Key
private enum MovieServiceKey: DependencyKey {
    static let liveValue: MovieServiceProtocol = MovieService()
    static let testValue: MovieServiceProtocol = MockMovieService()
}

// MARK: - Dependency Values Extension
extension DependencyValues {
    var movieService: MovieServiceProtocol {
        get { self[MovieServiceKey.self] }
        set { self[MovieServiceKey.self] = newValue }
    }
}

// MARK: - Mock Movie Service
final class MockMovieService: MovieServiceProtocol {
    
    // MARK: - Properties
    var movies: [Movie] = []
    var movieDetails: [String: Movie] = [:]
    var errors: [String: Error] = [:]
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie] {
        if let error = errors["movies_\(searchQuery)_\(page)"] {
            throw error
        }
        return movies
    }
    
    func fetchMovieDetails(imdbID: String) async throws -> Movie {
        if let error = errors["details_\(imdbID)"] {
            throw error
        }
        guard let movie = movieDetails[imdbID] else {
            throw NetworkError.noData
        }
        return movie
    }
    
    // MARK: - Configuration Methods
    
    func setMovies(_ movies: [Movie]) {
        self.movies = movies
    }
    
    func setMovieDetails(_ movie: Movie, for imdbID: String) {
        self.movieDetails[imdbID] = movie
    }
    
    func setError(_ error: Error, for key: String) {
        self.errors[key] = error
    }
}
