//
//  MovieListView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI

struct MovieListView: View {
    @State private var selectedMovie: Movie? = nil
    @State private var searchText = ""
    @State private var sortOption: SortOption = .title
    
    enum SortOption: String, CaseIterable {
        case title = "Title"
        case year = "Year"
        case rating = "Rating"
    }
    
    let movies: [Movie] = [
        Movie(id: 1,
              title: "Inception",
              overview: "Dream heist sci-fi thriller.",
              releaseDate: "2010",
              mediaType: "Movie",
              voteAverage: 8.8,
              posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
              backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
              staff: ["Christopher Nolan", "Leonardo DiCaprio"],
              runtime: 120,
              budget: 2349000.0
             ),
        Movie(
            id: 2,
            title: "Interstellar",
            overview: "Exploring space and time.",
            releaseDate: "2014",
            mediaType: "Movie",
            voteAverage: 8.6,
            posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
            backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
            staff: ["Christopher Nolan", "Matthew McConaughey"],
            runtime: 100,
            budget: 5349000.0
        )
    ]
    
    var filteredMovies: [Movie] {
        let filtered = searchText.isEmpty ? movies : movies.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .title:
            return filtered.sorted { $0.title < $1.title }
        case .year:
            return filtered.sorted {
                let year1 = Int($0.releaseDate ?? "") ?? 0
                let year2 = Int($1.releaseDate ?? "") ?? 0
                return year1 > year2
            }
        case .rating:
            return filtered.sorted { $0.voteAverage > $1.voteAverage }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Search movies...")
                    
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                
                // Movies List
                List {
                    ForEach(filteredMovies) { movie in
                        Button {
                            selectedMovie = movie
                        } label: {
                            MovieListRow(movie: movie)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowSeparatorTint(.gray.opacity(0.2))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}
