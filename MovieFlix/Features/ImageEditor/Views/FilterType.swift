//
//  ImageEditorView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType: String, CaseIterable {
    case sepia, noir, chrome, instant, process, transfer, tonal, vignette, bloom, gloom
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var ciFilter: CIFilter {
        switch self {
        case .sepia: return CIFilter.sepiaTone()
        case .noir: return CIFilter.photoEffectNoir()
        case .chrome: return CIFilter.photoEffectChrome()
        case .instant: return CIFilter.photoEffectInstant()
        case .process: return CIFilter.photoEffectProcess()
        case .transfer: return CIFilter.photoEffectTransfer()
        case .tonal: return CIFilter.photoEffectTonal()
        case .vignette: return CIFilter.vignette()
        case .bloom: return CIFilter.bloom()
        case .gloom: return CIFilter.gloom()
        }
    }
    
    var supportsIntensity: Bool {
        // Check which filters actually have intensity parameters
        switch self {
        case .sepia, .vignette, .bloom, .gloom:
            return true
        case .noir, .chrome, .instant, .process, .transfer, .tonal:
            return false
        }
    }
    
    var intensityKey: String {
        switch self {
        case .sepia: return kCIInputIntensityKey
        case .vignette: return kCIInputIntensityKey
        case .bloom: return kCIInputIntensityKey
        case .gloom: return kCIInputIntensityKey
        default: return kCIInputIntensityKey
        }
    }
}

struct FilterPreviewButton: View {
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
                if let previewImage = previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                } else {
                    Color.gray
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Text(filterType.displayName)
                    .font(.caption2)
                    .foregroundColor(.primary)
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
        
        // Use a smaller image for preview to optimize performance
        let scaledImage = inputImage.scaled(to: CGSize(width: 100, height: 100))
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processor = ImageFilterProcessor()
            let filteredImage = processor.applyFilter(
                to: scaledImage,
                filterType: filterType,
                intensity: 0.7 // Default preview intensity
            )
            
            DispatchQueue.main.async {
                previewImage = filteredImage
            }
        }
    }
}
