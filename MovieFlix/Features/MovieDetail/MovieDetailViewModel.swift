//
//  MovieDetailViewModel.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//


import Foundation
import Combine

class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var detailedMovie: Movie?
    
    private let movieService = MovieService()
    private var cancellables = Set<AnyCancellable>()
    
    init(movie: Movie) {
        self.movie = movie
        self.detailedMovie = movie.hasCompleteData ? movie : nil
    }
    
    func fetchMovieDetails() {
        // Only fetch if we don't already have complete data
        guard !movie.hasCompleteData && !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Use IMDb ID from the basic movie info
        movieService.fetchMovieDetails(imdbID: movie.imdbID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching movie details: \(error)")
                }
            } receiveValue: { [weak self] detailedMovie in
                self?.detailedMovie = detailedMovie
                print("Successfully loaded detailed movie info")
            }
            .store(in: &cancellables)
    }
}

// Add helper property to Movie model
extension Movie {
    var hasCompleteData: Bool {
        // Check if we already have detailed information
        return !(overview?.isEmpty ?? true) && 
               !(staff?.isEmpty ?? true) && 
               runtime != nil
    }
    
    // Helper to get IMDb ID from the id
    var imdbID: String {
        return "tt\(id)" // Convert numeric ID back to IMDb format
    }
}