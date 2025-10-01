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

            // Inline search loading indicator (only when searching)
            if store.isSearching {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Searching…")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

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
            if store.isLoadingInitial {
                loadingView
            } else if let _ = store.errorMessage {
                errorView
            } else {
                noMoviesView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        ProgressView("Loading \(APIUrls.Categories.displayName(for: store.selectedCategory)) movies…")
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
                // show pagination row
                LoadingRow(isLoading: store.isLoadingNextPage)
            }
        }
        .listStyle(PlainListStyle())
        // Pull-to-refresh (iOS 15+)
        .refreshable {
            store.send(.refresh)
        }
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

    private func handleMovieSelection(_ movie: Movie) {
        selectedMovie = movie
        store.send(.movieTapped(movie))
    }

    private func handlePagination(for movie: Movie) {
        // disable pagination while searching
        guard store.searchText.isEmpty else { return }

        if movie.id == store.movies.last?.id {
            store.send(.loadNextPage)
        }
    }
}

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
