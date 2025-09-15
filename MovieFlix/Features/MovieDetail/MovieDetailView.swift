//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct MovieDetailView: View {
    @Bindable var store: StoreOf<MovieDetailFeature>
    @State private var scrollOffset: CGFloat = 0
    @State private var showBottomSheet = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isEditingImage = false
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    private let headerHeight: CGFloat = 350
    
    init(movie: Movie) {
        self.store = Store(
            initialState: MovieDetailFeature.State(movie: movie),
            reducer: { MovieDetailFeature() }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background - use detailed movie if available
                BackgroundView(
                    backdropURL: store.displayMovie.backdropURL,
                    posterURL: store.displayMovie.posterURL,
                    geometry: geometry,
                    processedImage: processedImage
                )
                
                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header - use detailed movie if available
                        HeaderView(
                            movie: store.displayMovie,
                            scrollOffset: scrollOffset,
                            headerHeight: headerHeight,
                            geometry: geometry,
                            processedImage: processedImage
                        )
                        .frame(height: headerHeight)
                        
                        
                        
                        // Main Content - show loading or detailed content
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
                                onEditImage: {
                                    isEditingImage = true
                                }
                            )
                        }
                    }
                    .background(GeometryReader {
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scroll")).origin.y
                        )
                    })
                }
                .disabled(showBottomSheet)
                .coordinateSpace(name: "scroll")
                .ignoresSafeArea(edges: .top)
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    if !showBottomSheet { scrollOffset = value }
                }
                
                // Navigation Bar
                CustomNavigationBar(dismiss: dismiss)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetView(movie: store.displayMovie, isPresented: $showBottomSheet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $isEditingImage) {
            if let posterPath = store.displayMovie.posterPath {
                
                FullScreenImageEditorView(
                    inputImage: $inputImage,
                    processedImage: $processedImage,
                    isPresented: $isEditingImage
                )
                
//                FullScreenImageEditorView(
//                    store: Store(
//                        initialState: ImageEditorFeature.State(imageURL: posterPath),
//                        reducer: { ImageEditorFeature() }
//                    )
//                )
            }
        }
//        .sheet(isPresented: Binding(
//            get: { store.isImageEditorPresented },
//            set: { _ in store.send(.imageEditorDismissed) }
//        )) {
//            if let posterPath = store.displayMovie.posterPath {
//                FullScreenImageEditorView(
//                    store: Store(
//                        initialState: ImageEditorFeature.State(imageURL: posterPath),
//                        reducer: { ImageEditorFeature() }
//                    )
//                )
//            }
//        }
        .task {
            await loadInitialImage()
            // Fetch detailed movie info if needed
            if !store.movie.hasCompleteData {
                store.send(.fetchMovieDetails)
            }
        }
        .onChange(of: processedImage) { _, newImage in
            print("Image updated: \(newImage != nil)")
        }
    }
    
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
}

// Loading View for Detail
struct LoadingDetailView: View {
    var body: some View {
        VStack {
            ProgressView("Loading movie details...")
                .padding()
        }
        .frame(height: 200)
    }
}

// Error View for Detail
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
                        Image(uiImage: processedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                            .blur(radius: 20)
                            .opacity(0.3)
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
}

struct HeaderView: View {
    let movie: Movie
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    let geometry: GeometryProxy
    let processedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let processedImage = processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: headerHeight)
                    .clipped()
                    .offset(y: scrollOffset * 0.3)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                RemoteHeaderImage(
                    url: movie.backdropURL ?? movie.posterURL,
                    scrollOffset: scrollOffset,
                    geometry: geometry,
                    headerHeight: headerHeight
                )
            }
            
            // Movie Info Overlay
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
}

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Scroll offset tracking
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
