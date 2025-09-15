//
//  MovieService.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Foundation
import Dependencies

public protocol MovieServiceProtocol {
    func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie]
    func fetchMovieDetails(imdbID: String) async throws -> Movie
}

public final class MovieService: MovieServiceProtocol {
    @Dependency(\.httpClient) private var httpClient
    
    public init() {}
    
    public func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie] {
        guard let url = APIUrls.movieListURL(searchQuery: searchQuery, page: page) else {
            throw NetworkError.invalidURL
        }
        
        let request = Request<OMDbSearchResponse>(url: url)
        let response = try await httpClient.send(request)
        
        // Check if the API returned an error
        if response.response.lowercased() == "false", let errorMessage = response.error {
            throw NetworkError.serverError(400, errorMessage)
        }
        
        return response.movies.map { $0.toMovie() }
    }
    
    public func fetchMovieDetails(imdbID: String) async throws -> Movie {
        guard let url = APIUrls.movieDetailURL(imdbID: imdbID) else {
            throw NetworkError.invalidURL
        }
        
        let request = Request<OMDbMovieDetail>(url: url)
        let response = try await httpClient.send(request)
        
        return response.toMovie()
    }
}

// MARK: - Dependency Key
private enum MovieServiceKey: DependencyKey {
    static let liveValue: MovieServiceProtocol = MovieService()
    static let testValue: MovieServiceProtocol = MockMovieService()
}

extension DependencyValues {
    public var movieService: MovieServiceProtocol {
        get { self[MovieServiceKey.self] }
        set { self[MovieServiceKey.self] = newValue }
    }
}

// MARK: - Mock Service for Testing
public final class MockMovieService: MovieServiceProtocol {
    public var movies: [Movie] = []
    public var movieDetails: [String: Movie] = [:]
    public var errors: [String: Error] = [:]
    
    public init() {}
    
    public func fetchMovies(searchQuery: String, page: Int) async throws -> [Movie] {
        if let error = errors["movies_\(searchQuery)_\(page)"] {
            throw error
        }
        return movies
    }
    
    public func fetchMovieDetails(imdbID: String) async throws -> Movie {
        if let error = errors["details_\(imdbID)"] {
            throw error
        }
        guard let movie = movieDetails[imdbID] else {
            throw NetworkError.noData
        }
        return movie
    }
    
    public func setMovies(_ movies: [Movie]) {
        self.movies = movies
    }
    
    public func setMovieDetails(_ movie: Movie, for imdbID: String) {
        self.movieDetails[imdbID] = movie
    }
    
    public func setError(_ error: Error, for key: String) {
        self.errors[key] = error
    }
}
