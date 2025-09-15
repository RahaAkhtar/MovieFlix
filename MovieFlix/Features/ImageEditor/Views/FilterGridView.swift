//
//  FilterGridView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

// MARK: - Filter Grid View
/// A horizontal scrollable grid of filter options with preview images
struct FilterGridView: View {
    // MARK: - Properties
    let inputImage: UIImage?
    @Binding var selectedFilterType: FilterType
    let onFilterSelected: (FilterType) -> Void
    
    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(FilterType.allCases, id: \.self) { filterType in
                    FilterOptionView(
                        filterType: filterType,
                        isSelected: selectedFilterType == filterType,
                        inputImage: inputImage,
                        onSelect: onFilterSelected
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Filter Option View
/// Individual filter option with preview image and selection state
struct FilterOptionView: View {
    // MARK: - Properties
    let filterType: FilterType
    let isSelected: Bool
    let inputImage: UIImage?
    let onSelect: (FilterType) -> Void
    
    // MARK: - State
    @State private var previewImage: UIImage?
    
    // MARK: - Body
    var body: some View {
        Button {
            handleFilterSelection()
        } label: {
            VStack(spacing: 8) {
                // Filter preview image container
                previewImageContainer
                
                // Filter name label
                filterNameLabel
            }
        }
        .onAppear {
            generatePreview()
        }
        .onChange(of: inputImage) { _, _ in
            regeneratePreview()
        }
    }
    
    // MARK: - Subviews
    
    /// Container for the filter preview image with selection indicator
    private var previewImageContainer: some View {
        ZStack {
            // Preview image or placeholder
            if let previewImage = previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
            }
            
            // Selection border
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
            
            // Selection checkmark indicator
            if isSelected {
                selectionIndicator
            }
        }
    }
    
    /// Checkmark indicator for selected filter
    private var selectionIndicator: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.blue)
            .background(Circle().fill(Color.white))
            .offset(x: 25, y: 25)
    }
    
    /// Label displaying the filter name
    private var filterNameLabel: some View {
        Text(filterType.displayName)
            .font(.caption2)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundColor(.primary)
            .frame(width: 70)
            .lineLimit(1)
    }
    
    // MARK: - Action Methods
    
    /// Handles filter selection tap
    private func handleFilterSelection() {
        onSelect(filterType)
    }
    
    // MARK: - Preview Generation Methods
    
    /// Generates preview image for the filter option
    private func generatePreview() {
        guard let inputImage = inputImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            generateFilteredPreview(inputImage: inputImage)
        }
    }
    
    /// Regenerates preview when input image changes
    private func regeneratePreview() {
        previewImage = nil // Clear previous preview
        generatePreview()
    }
    
    /// Generates filtered preview image on background thread
    private func generateFilteredPreview(inputImage: UIImage) {
        let processor = ImageFilterProcessor()
        
        // Use appropriate intensity for preview
        let previewIntensity: Double = filterType.supportsIntensity ? 0.7 : 1.0
        
        // Scale down image for performance
        let scaledImage = inputImage.scaled(to: CGSize(width: 100, height: 100))
        
        let filteredImage = processor.applyFilter(
            to: scaledImage,
            filterType: filterType,
            intensity: previewIntensity
        )
        
        // Update UI on main thread
        DispatchQueue.main.async {
            previewImage = filteredImage
        }
    }
}

