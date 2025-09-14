//
//  OMDbMovieDetail.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Foundation

struct OMDbMovieDetail: Codable {
    let title: String?
    let year: String?
    let rated: String?
    let released: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let poster: String?
    let imdbRating: String?
    let imdbID: String?
    let boxOffice: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case poster = "Poster"
        case imdbRating
        case imdbID
        case boxOffice = "BoxOffice"
    }
    
    func toMovie() -> Movie {
        // Parse runtime (e.g., "142 min" -> 142)
        let runtimeMinutes = parseRuntime(runtimeString: runtime)
        
        // Parse box office (e.g., "$100,000,000" -> 100000000.0)
        let budgetValue = parseBoxOffice(boxOfficeString: boxOffice)
        
        // Create staff array from director, writer, actors
        var staff: [String] = []
        if let director = director, !director.isEmpty {
            staff.append("Director: \(director)")
        }
        if let writer = writer, !writer.isEmpty {
            staff.append("Writer: \(writer)")
        }
        if let actors = actors, !actors.isEmpty {
            staff.append("Cast: \(actors)")
        }
        
        return Movie(
            id: parseIMDbID(imdbID: imdbID ?? ""),
            title: title ?? "",
            overview: plot ?? "No description available",
            releaseDate: year,
            mediaType: "Movie",
            voteAverage: Double(imdbRating ?? "0") ?? 0.0,
            posterPath: poster,
            backdropPath: poster, // OMDb doesn't provide backdrop, use poster as fallback
            staff: staff,
            runtime: runtimeMinutes,
            budget: budgetValue
        )
    }
    
    private func parseRuntime(runtimeString: String?) -> Int? {
        guard let runtimeString = runtimeString else { return nil }
        
        // Extract numbers from strings like "142 min", "2 h 22 min", etc.
        let numericPart = runtimeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        return Int(numericPart)
    }
    
    private func parseBoxOffice(boxOfficeString: String?) -> Double? {
        guard let boxOfficeString = boxOfficeString else { return nil }
        
        // Remove currency symbols and commas
        let numericString = boxOfficeString
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        return Double(numericString)
    }
    
    private func parseIMDbID(imdbID: String) -> Int {
        // Remove "tt" prefix and convert to Int
        let numericID = imdbID.replacingOccurrences(of: "tt", with: "")
        return Int(numericID) ?? 0
    }
}
