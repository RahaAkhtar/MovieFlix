//
//  MovieListViewModel.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 14/09/2025.
//


import Foundation
import Combine

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var selectedCategory: String = APIUrls.Categories.action
    
    private var currentPage = 1
    private let movieService = MovieService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load initial movies
        fetchMovies()
    }
    
    func fetchMovies() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        movieService.fetchMovies(searchQuery: selectedCategory, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] movies in
                self?.movies.append(contentsOf: movies)
                self?.currentPage += 1
                self?.hasMorePages = !movies.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func loadNextPageIfNeeded(currentMovie: Movie) {
        if currentMovie.id == movies.last?.id {
            fetchMovies()
        }
    }
    
    func retry() {
        fetchMovies()
    }
    
    func selectCategory(_ category: String) {
        guard category != selectedCategory else { return }
        
        // Reset for new category
        selectedCategory = category
        movies = []
        currentPage = 1
        hasMorePages = true
        
        fetchMovies()
    }
}
