//
//  MovieListView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct MovieListView: View {
    @Bindable var store: StoreOf<MovieListFeature>
    @State private var selectedMovie: Movie? = nil
    
    init(store: StoreOf<MovieListFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker - Always at the top
                CategoryPickerView(
                    selectedCategory: $store.selectedCategory.sending(\.selectCategory),
                    categories: APIUrls.Categories.all,
                    onCategorySelected: { category in
                        store.send(.selectCategory(category))
                    }
                )
                
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(
                        text: $store.searchText.sending(\.searchTextChanged),
                        placeholder: "Search movies..."
                    )
                    
                    Picker("Sort by", selection: $store.sortOption.sending(\.sortOptionChanged)) {
                        ForEach(MovieListFeature.State.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                
                // Movies List Content
                ZStack {
                    if store.movies.isEmpty {
                        if store.isLoading {
                            ProgressView("Loading \(APIUrls.Categories.displayName(for: store.selectedCategory)) movies...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = store.errorMessage {
                            ErrorView(error: error, onRetry: {
                                store.send(.retry)
                            })
                        } else {
                            Text("No movies found")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        List {
                            ForEach(store.filteredMovies) { movie in
                                Button {
                                    selectedMovie = movie
                                    store.send(.movieTapped(movie))
                                } label: {
                                    MovieListRow(movie: movie)
                                        .onAppear {
                                            if movie.id == store.movies.last?.id {
                                                store.send(.loadNextPage)
                                            }
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .listRowSeparatorTint(.gray.opacity(0.2))
                                .listRowBackground(Color.clear)
                            }
                            
                            if store.hasMorePages && store.searchText.isEmpty {
                                LoadingRow(isLoading: store.isLoading)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("MovieFlix")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// Loading row for pagination
struct LoadingRow: View {
    let isLoading: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
            } else {
                Text("Pull to load more")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Previews
#Preview {
    MovieListView(
        store: Store(
            initialState: MovieListFeature.State(),
            reducer: { MovieListFeature() }
        )
    )
}

#Preview("Loading State") {
    MovieListView(
        store: Store(
            initialState: MovieListFeature.State(isLoading: true),
            reducer: { MovieListFeature() }
        )
    )
}

#Preview("Error State") {
    MovieListView(
        store: Store(
            initialState: MovieListFeature.State(
                errorMessage: "Failed to load movies. Please check your internet connection."
            ),
            reducer: { MovieListFeature() }
        )
    )
}
