//
//  Movie.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public struct Movie: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let releaseDate: String?
    public let mediaType: String
    public let voteAverage: Double
    public let posterPath: String?
    public let backdropPath: String?
    let staff: [String]?
    let runtime: Int?
    let budget: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case mediaType = "media_type"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case staff
        case runtime
        case budget
    }
}

public extension Movie {
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
    
    var year: String? {
        guard let releaseDate = releaseDate else { return nil }
        return String(releaseDate.prefix(4))
    }
}


//struct Movie: Identifiable {
//    let id: Int
//    let title: String
//    let overview: String
//    let releaseDate: String
//    let mediaType: String
//    let voteAverage: Double
//    let posterName: String // use asset catalog or system placeholder
//    let staff: [String]
//}
