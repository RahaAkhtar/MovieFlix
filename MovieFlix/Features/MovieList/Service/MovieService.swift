//
//  MovieService.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//

import Foundation
import Combine

class MovieService {
    
    func fetchMovies(searchQuery: String, page: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = APIUrls.movieListURL(searchQuery: searchQuery, page: page) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Fetching movies: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> Data in
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response: \(jsonString)")
                }
                return data
            }
            .tryMap { data -> [Movie] in
                let response = try JSONDecoder().decode(OMDbSearchResponse.self, from: data)
                
                // Check if the API returned an error
                if response.response.lowercased() == "false", let errorMessage = response.error {
                    throw NSError(domain: "OMDbAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                
                // Return mapped movies or empty array if search is nil
                return response.movies.map { $0.toMovie() }
            }
            .eraseToAnyPublisher()
    }
    
    // In MovieService, enhance the fetchMovieDetails method:
    func fetchMovieDetails(imdbID: String) -> AnyPublisher<Movie, Error> {
        guard let url = APIUrls.movieDetailURL(imdbID: imdbID) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Fetching movie details: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> Data in
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Detail API Response: \(jsonString)")
                }
                return data
            }
            .decode(type: OMDbMovieDetail.self, decoder: JSONDecoder())
            .map { detailResponse -> Movie in
                // Convert OMDb detail response to Movie
                return detailResponse.toMovie()
            }
            .eraseToAnyPublisher()
    }
}
