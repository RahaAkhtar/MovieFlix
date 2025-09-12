//
//  MovieServiceProtocol.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public protocol MovieServiceProtocol {
    func fetchMovies(page: Int) async throws -> [Movie]
}

import Foundation

public final class MovieService: MovieServiceProtocol {
    private let client: HTTPClient
    private let apiKey = "a64ee144" // 👈 replace with your key
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func fetchMovies(page: Int) async throws -> [Movie] {
        let url = URL(string: "https://www.omdbapi.com/?s=batman&page=\(page)&apikey=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(OMDbSearchResponse.self, from: data)
        return response.search.map { $0.toMovie() }
    }
}

// MARK: - OMDb Response Models
struct OMDbSearchResponse: Codable {
    let search: [OMDbMovie]
    enum CodingKeys: String, CodingKey { case search = "Search" }
}

struct OMDbMovie: Codable {
    let imdbID: String
    let title: String
    let year: String
    let type: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case imdbID, title = "Title", year = "Year", type = "Type", poster = "Poster"
    }
    
    func toMovie() -> Movie {
        Movie(
            id: imdbID.hashValue,
            title: title,
            overview: "",
            releaseDate: year,
            mediaType: type,
            voteAverage: 0,
            posterPath: poster,
            backdropPath: nil,
            staff: [],
            runtime: 10,
            budget: 20.0
        )
    }
}

