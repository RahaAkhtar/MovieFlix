//
//  FullScreenImageEditorView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import SwiftUI
import Kingfisher

// MARK: - Main Image Editor View
struct FullScreenImageEditorView: View {
    // MARK: - Binding Properties
    @Binding var inputImage: UIImage?
    @Binding var processedImage: UIImage?
    @Binding var isPresented: Bool
    
    // MARK: - State Properties
    @State private var workingImage: UIImage?
    @State private var filterIntensity: Double = 0.5
    @State private var selectedFilterType: FilterType = .sepia
    
    // MARK: - Dependencies
    private let filterProcessor = ImageFilterProcessor()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Image preview area
                imagePreviewSection
                
                // Editor controls
                EditorControlsView(
                    inputImage: inputImage,
                    workingImage: $workingImage,
                    filterIntensity: $filterIntensity,
                    selectedFilterType: $selectedFilterType
                )
                .padding()
                .padding(.bottom, 60)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Edit Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                // Save button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        processedImage = workingImage
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                initializeEditor()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Image preview section with black background
    private var imagePreviewSection: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = workingImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.6)
    }
    
    // MARK: - Methods
    
    /// Initializes the editor with current processed image or original input image
    private func initializeEditor() {
        workingImage = processedImage ?? inputImage
    }
}

// MARK: - Editor Controls View
struct EditorControlsView: View {
    // MARK: - Properties
    let inputImage: UIImage?
    @Binding var workingImage: UIImage?
    @Binding var filterIntensity: Double
    @Binding var selectedFilterType: FilterType
    
    // MARK: - Dependencies
    private let filterProcessor = ImageFilterProcessor()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Filter selection section
            filterSelectionSection
            
            // Intensity control section
            intensityControlSection
            
            // Action buttons section
            actionButtonsSection
        }
        .onChange(of: selectedFilterType) { _, _ in
            applyCurrentFilter()
        }
    }
    
    // MARK: - Subviews
    
    /// Filter selection grid with available filters
    private var filterSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
            
            FilterGridView(
                inputImage: inputImage,
                selectedFilterType: $selectedFilterType,
                onFilterSelected: { filterType in
                    selectedFilterType = filterType
                    filterIntensity = 0.5
                    applyCurrentFilter()
                }
            )
        }
    }
    
    /// Intensity control slider with conditional enablement
    private var intensityControlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Intensity: \(Int(filterIntensity * 100))%")
                    .font(.subheadline)
                    .foregroundColor(selectedFilterType.supportsIntensity ? .primary : .secondary)
                
                Spacer()
                
                if !selectedFilterType.supportsIntensity {
                    Text("Not adjustable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Slider(value: $filterIntensity, in: 0...1, step: 0.01)
                .disabled(!selectedFilterType.supportsIntensity)
                .opacity(selectedFilterType.supportsIntensity ? 1.0 : 0.6)
                .onChange(of: filterIntensity) { _, _ in
                    applyCurrentFilter()
                }
        }
    }
    
    /// Action buttons for editor operations
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Button("Revert to Original") {
                revertToOriginal()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Filter Methods
    
    /// Applies the currently selected filter with intensity
    private func applyCurrentFilter() {
        guard let inputImage = inputImage else { return }
        
        let intensity = selectedFilterType.supportsIntensity ? filterIntensity : 1.0
        
        workingImage = filterProcessor.applyFilter(
            to: inputImage,
            filterType: selectedFilterType,
            intensity: intensity
        )
    }
    
    /// Reverts the image to original state and resets filter settings
    private func revertToOriginal() {
        workingImage = inputImage
        filterIntensity = 0.5
        selectedFilterType = .sepia // Reset to default filter
    }
}
