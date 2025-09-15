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
                backgroundView(geometry: geometry)
                contentView(geometry: geometry)
                navigationBar
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

// MARK: - Background View
struct BackgroundView: View {
    let backdropURL: URL?
    let posterURL: URL?
    let geometry: GeometryProxy
    let processedImage: UIImage?
    
    var body: some View {
        Color.clear
            .background(
                Group {
                    if let processedImage = processedImage {
                        processedImageView
                    } else {
                        RemoteBlurBackground(
                            url: backdropURL ?? posterURL,
                            geometry: geometry
                        )
                    }
                }
            )
            .frame(height: geometry.safeAreaInsets.top + 100)
            .ignoresSafeArea()
    }
    
    private var processedImageView: some View {
        Image(uiImage: processedImage!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width)
            .blur(radius: 20)
            .opacity(0.3)
    }
}

// MARK: - Header View
struct HeaderView: View {
    let movie: Movie
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    let geometry: GeometryProxy
    let processedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundImage
            movieInfoOverlay
        }
    }
    
    private var backgroundImage: some View {
        Group {
            if let processedImage = processedImage {
                processedBackgroundImage
            } else {
                remoteBackgroundImage
            }
        }
    }
    
    private var processedBackgroundImage: some View {
        Image(uiImage: processedImage!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: headerHeight)
            .clipped()
            .offset(y: scrollOffset * 0.3)
            .overlay(gradientOverlay)
    }
    
    private var remoteBackgroundImage: some View {
        RemoteHeaderImage(
            url: movie.backdropURL ?? movie.posterURL,
            scrollOffset: scrollOffset,
            geometry: geometry,
            headerHeight: headerHeight
        )
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var movieInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(movie.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 20) {
                InfoBadgeView.rating(movie.voteAverage)
                InfoBadgeView.year(movie.releaseDate ?? "Unknown")
                InfoBadgeView.mediaType(movie.mediaType)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Scroll Offset Preference Key
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
