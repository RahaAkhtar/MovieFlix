//
//  MovieListView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture


// MARK: - Movie List View
struct MovieListView: View {
    
    // MARK: - Properties
    @Bindable var store: StoreOf<MovieListFeature>
    @State private var selectedMovie: Movie? = nil
    
    // MARK: - Initialization
    init(store: StoreOf<MovieListFeature>) {
        self.store = store
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                categoryPicker
                searchAndFilterBar
                moviesListContent
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
    
    // MARK: - Subviews
    
    private var categoryPicker: some View {
        CategoryPickerView(
            selectedCategory: $store.selectedCategory.sending(\.selectCategory),
            categories: APIUrls.Categories.all,
            onCategorySelected: { category in
                store.send(.selectCategory(category))
            }
        )
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            SearchBar(
                text: $store.searchText.sending(\.searchTextChanged),
                placeholder: "Search movies..."
            )
            
            sortPicker
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private var sortPicker: some View {
        Picker("Sort by", selection: $store.sortOption.sending(\.sortOptionChanged)) {
            ForEach(MovieListFeature.State.SortOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var moviesListContent: some View {
        ZStack {
            if store.movies.isEmpty {
                emptyStateView
            } else {
                moviesListView
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        Group {
            if store.isLoading {
                loadingView
            } else if let error = store.errorMessage {
                errorView
            } else {
                noMoviesView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        ProgressView("Loading \(APIUrls.Categories.displayName(for: store.selectedCategory)) movies...")
    }
    
    private var errorView: some View {
        ErrorView(error: store.errorMessage ?? "Unknown error", onRetry: {
            store.send(.retry)
        })
    }
    
    private var noMoviesView: some View {
        Text("No movies found")
            .foregroundColor(.secondary)
    }
    
    private var moviesListView: some View {
        List {
            ForEach(store.filteredMovies) { movie in
                movieRow(movie: movie)
            }
            
            if store.hasMorePages && store.searchText.isEmpty {
                loadingRow
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func movieRow(movie: Movie) -> some View {
        Button {
            handleMovieSelection(movie)
        } label: {
            MovieListRow(movie: movie)
                .onAppear {
                    handlePagination(for: movie)
                }
        }
        .buttonStyle(PlainButtonStyle())
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .listRowSeparatorTint(.gray.opacity(0.2))
        .listRowBackground(Color.clear)
    }
    
    private var loadingRow: some View {
        LoadingRow(isLoading: store.isLoading)
            .listRowBackground(Color.clear)
    }
    
    // MARK: - Methods
    
    private func handleMovieSelection(_ movie: Movie) {
        selectedMovie = movie
        store.send(.movieTapped(movie))
    }
    
    private func handlePagination(for movie: Movie) {
        if movie.id == store.movies.last?.id {
            store.send(.loadNextPage)
        }
    }
}

// MARK: - Loading Row
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
