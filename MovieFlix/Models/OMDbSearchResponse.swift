//
//  OMDbSearchResponse.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//


struct OMDbSearchResponse: Codable {
    let search: [OMDbMovie]?
    let totalResults: String?
    let response: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
        case error = "Error"
    }
    
    // Helper property to handle optional search array
    var movies: [OMDbMovie] {
        search ?? []
    }
}

struct OMDbMovie: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
    
    func toMovie() -> Movie {
        Movie(
            id: Int(imdbID.filter { $0.isNumber }) ?? 0,
            title: title,
            overview: "Description not available from search results", // OMDb doesn't provide overview in search
            releaseDate: year,
            mediaType: type,
            voteAverage: Double.random(in: 5...9), // Random rating since OMDb search doesn't provide it
            posterPath: poster,
            backdropPath: "", // OMDb doesn't provide backdrop in search
            staff: [], // OMDb doesn't provide staff in search
            runtime: nil,
            budget: nil
        )
    }
}
