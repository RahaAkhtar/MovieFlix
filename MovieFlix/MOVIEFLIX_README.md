MovieFlix - iOS App with The Composable Architecture

MovieFlix is a modern iOS application built with SwiftUI and The Composable Architecture (TCA) that allows users to browse, search, and explore movies with a beautiful, intuitive interface.

Architecture Overview

MovieFlix is built using The Composable Architecture (TCA), a powerful state management framework that provides:

Unidirectional data flow for predictable state changes
Testable features with isolated reducers and effects
Dependency injection for easy testing and modularity
Type-safe state management with compile-time guarantees
Key Features

🎬 Movie Browsing

Discover popular movies with paginated lists
Search functionality with real-time results
Detailed movie information with rich metadata
🎨 Image Editing

Built-in image editor for movie posters
Multiple filter options and adjustments
Real-time preview and saving capabilities
📱 Modern UI

SwiftUI-based interface with smooth animations
Custom navigation and transition effects
Adaptive layout for all device sizes
Technical Architecture

Core Components

Network Layer

Generic HTTPClient with type-safe requests
URLSession-based implementation for production
Mock implementations for testing and previews
Comprehensive error handling with NetworkError enum

Dependency Management
@Dependency(\.movieService) var movieService
@Dependency(\.imageService) var imageService

Feature Structure

Each feature follows the TCA pattern:

@Reducer
struct MovieListFeature {
    @ObservableState
    struct State: Equatable { /* ... */ }
    
    enum Action: Equatable { /* ... */ }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // State management logic
        }
    }
}   


Featured Modules

MovieListFeature

Handles movie discovery and search
Pagination and loading states
Error handling and retry logic
MovieDetailFeature

Fetches and displays detailed movie information
Manages image editor presentation
Handles user interactions and state
ImageEditorFeature

Image loading and processing pipeline
Filter application and adjustments
Image saving functionality
API Integration

The app integrates with the OMDb API for movie data:

Search Endpoint: ?s={query}&page={page}&apikey={key}
Details Endpoint: ?i={imdbID}&apikey={key}
Getting Started

Prerequisites

iOS 15.0+
Xcode 13.0+
Swift 5.5+
Installation

Clone the repository:
bash
git clone https://github.com/your-username/MovieFlix.git
Open MovieFlix.xcodeproj in Xcode
Add your OMDb API key in DependencyConfiguration.swift:
swift
DependencyValues.movieService = LiveMovieService(apiKey: "YOUR_API_KEY")
Build and run the project
Running Tests

bash
xcodebuild test -scheme MovieFlix -destination 'platform=iOS Simulator,name=iPhone 15'
Project Structure

MovieApp/
├── MovieApp.swift
├── App/
│   └── AppFeature.swift
├── Core/
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   └── Endpoints.swift
│   └── Utils/
│       ├── ImageProcessor.swift
│       └── PerformanceMonitor.swift
├── Features/
│   ├── MovieList/
│   │   ├── The List Implementation
│   ├── MovieDetail/
│   │   ├── The Movie Details Implementation
│   └── ImageEditor/
│       ├── The Image Editor Implementation
└── Models/
    ├── Movie.swift
    └── Filter.swift
    
    
Key Dependencies

swift-composable-architecture: Core architecture framework
Kingfisher: Image loading and caching
swift-dependencies: Dependency management

License

This project is licensed under the MIT License - see the LICENSE file for details.

Resources

TCA Documentation
SwiftUI Documentation
OMDb API Documentation
Support

For questions and support:

Open an issue on GitHub
Check the documentation links above
Review existing test cases for implementation examples
