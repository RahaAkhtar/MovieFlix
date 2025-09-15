//
//  APIUrls.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Foundation

public struct APIUrls {
    private static let baseURL = "https://www.omdbapi.com/"
    private static let apiKey = "205d20b5"
    
    // MARK: - Movie List URLs
    public static func movieListURL(searchQuery: String, page: Int) -> URL? {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        let urlString = "\(baseURL)?s=\(encodedQuery)&page=\(page)&apikey=\(apiKey)"
        return URL(string: urlString)
    }
    
    // MARK: - Movie Detail URL
    public static func movieDetailURL(imdbID: String) -> URL? {
        let urlString = "\(baseURL)?i=\(imdbID)&apikey=\(apiKey)"
        return URL(string: urlString)
    }
    
    // MARK: - Popular Movie Categories
    public struct Categories {
        public static let action = "action"
        public static let comedy = "comedy"
        public static let drama = "drama"
        public static let adventure = "adventure"
        public static let horror = "horror"
        public static let sciFi = "sci-fi"
        public static let thriller = "thriller"
        public static let animation = "animation"
        public static let fantasy = "fantasy"
        
        public static let all: [String] = [
            action, comedy, drama, adventure, 
            horror, sciFi, thriller, animation, fantasy
        ]
        
        public static func displayName(for category: String) -> String {
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
