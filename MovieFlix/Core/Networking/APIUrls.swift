//
//  APIUrls.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//


import Foundation

struct APIUrls {
    private static let baseURL = "https://www.omdbapi.com/"
    private static let apiKey = "205d20b5"
    
    // MARK: - Movie List URLs
    static func movieListURL(searchQuery: String, page: Int) -> URL? {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "\(baseURL)?s=\(encodedQuery)&page=\(page)&apikey=\(apiKey)"
        return URL(string: urlString)
    }
    
    // MARK: - Movie Detail URL
    static func movieDetailURL(imdbID: String) -> URL? {
        let urlString = "\(baseURL)?i=\(imdbID)&apikey=\(apiKey)"
        return URL(string: urlString)
    }
    
    // MARK: - Popular Movie Categories
    struct Categories {
        static let action = "action"
        static let comedy = "comedy"
        static let drama = "drama"
        static let adventure = "adventure"
        static let horror = "horror"
        static let sciFi = "sci-fi"
        static let thriller = "thriller"
        static let animation = "animation"
        static let fantasy = "fantasy"
        
        static let all: [String] = [
            action, comedy, drama, adventure, 
            horror, sciFi, thriller, animation, fantasy
        ]
        
        static func displayName(for category: String) -> String {
            switch category {
            case action: return "Action"
            case comedy: return "Comedy"
            case drama: return "Drama"
            case adventure: return "Adventure"
            case horror: return "Horror"
            case sciFi: return "Sci-Fi"
            case thriller: return "Thriller"
            case animation: return "Animation"
            case fantasy: return "Fantasy"
            default: return category.capitalized
            }
        }
    }
}
