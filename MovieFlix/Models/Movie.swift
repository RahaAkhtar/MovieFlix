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
        return URL(string: path)
    }
    
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: path)
    }
    
    var year: String? {
        guard let releaseDate = releaseDate else { return nil }
        return String(releaseDate.prefix(4))
    }
}


extension Movie {
    var hasCompleteData: Bool {
        // Use the properties that actually exist in your model
        let hasOverview = !(overview ?? "").isEmpty
        let hasStaff = !(staff ?? []).isEmpty
        let hasRuntime = (runtime ?? 0) > 0
        let hasBudget = (budget ?? 0) > 0
        
        // Adjust this based on what constitutes "complete data" for your app
        return hasOverview && hasStaff && hasRuntime && hasBudget
    }
    
    var hasImages: Bool {
        backdropURL != nil || posterURL != nil
    }
    
    var shouldShowButtons: Bool {
        hasCompleteData || hasImages
    }
    
    // Helper to get IMDb ID from the id
    var imdbID: String {
        return "tt\(id)" // Convert numeric ID back to IMDb format
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
