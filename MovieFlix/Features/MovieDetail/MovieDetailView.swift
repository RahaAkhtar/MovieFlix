//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Movie Detail View
struct MovieDetailView: View {
    
    // MARK: - Properties
    @Bindable var store: StoreOf<MovieDetailFeature>
    @State private var scrollOffset: CGFloat = 0
    @State private var showBottomSheet = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isEditingImage = false
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    private let headerHeight: CGFloat = 350
    
    // MARK: - Initialization
    init(movie: Movie) {
        self.store = Store(
            initialState: MovieDetailFeature.State(movie: movie),
            reducer: { MovieDetailFeature() }
        )
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                if store.displayMovie.shouldShowButtons {
                    backgroundView(geometry: geometry)
                    contentView(geometry: geometry)
                    navigationBar
                } else {
                    noDataView(geometry: geometry)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBottomSheet) {
            bottomSheetView
        }
        .sheet(isPresented: $isEditingImage) {
            imageEditorView
        }
        .task {
            await loadInitialImage()
            fetchMovieDetailsIfNeeded()
        }
        .onChange(of: processedImage) { _, newImage in
            handleImageUpdate(newImage)
        }
    }
    
    // MARK: - Subviews
    
    private func noDataView(geometry: GeometryProxy) -> some View {
        NoDataView.movieNoData(
            frame: CGSize(width: geometry.size.width, height: geometry.size.height),
            dismissAction: { dismiss() }
        )
    }
    
    private func backgroundView(geometry: GeometryProxy) -> some View {
        BackgroundView(
            backdropURL: store.displayMovie.backdropURL,
            posterURL: store.displayMovie.posterURL,
            geometry: geometry,
            processedImage: processedImage
        )
    }
    
    private func contentView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView(geometry: geometry)
                mainContentView
            }
            .background(scrollOffsetTracker)
        }
        .disabled(showBottomSheet)
        .coordinateSpace(name: "scroll")
        .ignoresSafeArea(edges: .top)
        .onPreferenceChange(ViewOffsetKey.self) { value in
            updateScrollOffset(value)
        }
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        HeaderView(
            movie: store.displayMovie,
            scrollOffset: scrollOffset,
            headerHeight: headerHeight,
            geometry: geometry,
            processedImage: processedImage
        )
        .frame(height: headerHeight)
    }
    
    private var mainContentView: some View {
        Group {
            if store.isLoading {
                LoadingDetailView()
            } else if let error = store.errorMessage {
                ErrorDetailView(error: error, onRetry: {
                    store.send(.retry)
                })
            } else {
                MovieDetailContentView(
                    movie: store.displayMovie,
                    onShowDetails: { showBottomSheet = true },
                    onEditImage: { isEditingImage = true }
                )
            }
        }
    }
    
    private var scrollOffsetTracker: some View {
        GeometryReader {
            Color.clear.preference(
                key: ViewOffsetKey.self,
                value: -$0.frame(in: .named("scroll")).origin.y
            )
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(dismiss: dismiss)
    }
    
    private var bottomSheetView: some View {
        BottomSheetView(movie: store.displayMovie, isPresented: $showBottomSheet)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
    }
    
    private var imageEditorView: some View {
        Group {
            if let posterPath = store.displayMovie.posterPath {
                FullScreenImageEditorView(
                    inputImage: $inputImage,
                    processedImage: $processedImage,
                    isPresented: $isEditingImage
                )
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadInitialImage() async {
        guard let url = store.movie.backdropURL ?? store.movie.posterURL else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.inputImage = uiImage
                }
            }
        } catch {
            print("Failed to preload image for editor: \(error)")
        }
    }
    
    private func fetchMovieDetailsIfNeeded() {
        if !store.movie.hasCompleteData {
            store.send(.fetchMovieDetails)
        }
    }
    
    private func updateScrollOffset(_ value: CGFloat) {
        if !showBottomSheet { scrollOffset = value }
    }
    
    private func handleImageUpdate(_ newImage: UIImage?) {
        print("Image updated: \(newImage != nil)")
    }
}

// MARK: - Loading Detail View
struct LoadingDetailView: View {
    var body: some View {
        VStack {
            ProgressView("Loading movie details...")
                .padding()
        }
        .frame(height: 200)
    }
}

// MARK: - Error Detail View
struct ErrorDetailView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Couldn't load details")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(height: 200)
    }
}
