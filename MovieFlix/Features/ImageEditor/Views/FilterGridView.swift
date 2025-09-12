//
//  FilterGridView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 12/09/2025.
//

import SwiftUI

struct FilterGridView: View {
    let inputImage: UIImage?
    @Binding var selectedFilterType: FilterType
    let onFilterSelected: (FilterType) -> Void
    
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

struct FilterOptionView: View {
    let filterType: FilterType
    let isSelected: Bool
    let inputImage: UIImage?
    let onSelect: (FilterType) -> Void
    
    @State private var previewImage: UIImage?
    
    var body: some View {
        Button {
            onSelect(filterType)
        } label: {
            VStack(spacing: 8) {
                ZStack {
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
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .offset(x: 25, y: 25)
                    }
                }
                
                Text(filterType.displayName)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.primary)
                    .frame(width: 70)
                    .lineLimit(1)
            }
        }
        .onAppear {
            generatePreview()
        }
        .onChange(of: inputImage) { _, _ in
            generatePreview()
        }
    }
    
    private func generatePreview() {
        guard let inputImage = inputImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processor = ImageFilterProcessor()
            
            // Use appropriate intensity for preview
            let previewIntensity: Double = filterType.supportsIntensity ? 0.7 : 1.0
            
            let filteredImage = processor.applyFilter(
                to: inputImage.scaled(to: CGSize(width: 100, height: 100)),
                filterType: filterType,
                intensity: previewIntensity
            )
            
            DispatchQueue.main.async {
                previewImage = filteredImage
            }
        }
    }
}
