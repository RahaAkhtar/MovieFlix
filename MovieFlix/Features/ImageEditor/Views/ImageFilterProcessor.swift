//
//  ImageFilterProcessor.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Image Filter Processor
/// Handles image filtering operations using Core Image filters
class ImageFilterProcessor {
    
    // MARK: - Properties
    
    /// Core Image context for image processing
    private let context = CIContext()
    
    // MARK: - Public Methods
    
    /// Applies the specified filter to the input image with given intensity
    /// - Parameters:
    ///   - image: The input UIImage to apply filters to
    ///   - filterType: The type of filter to apply
    ///   - intensity: The intensity of the filter effect (0.0 to 1.0)
    /// - Returns: The filtered UIImage, or original image if filtering fails
    func applyFilter(to image: UIImage, filterType: FilterType, intensity: Double) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = filterType.ciFilter
        
        // Set input image for the filter
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Configure filter parameters based on type
        configureFilterParameters(filter: filter, filterType: filterType, intensity: intensity)
        
        // Process and return the filtered image
        return processFilterOutput(filter: filter, originalImage: image)
    }
    
    // MARK: - Private Methods
    
    /// Configures filter parameters based on filter type and intensity
    /// - Parameters:
    ///   - filter: The CIFilter to configure
    ///   - filterType: The type of filter being applied
    ///   - intensity: The intensity value for the filter
    private func configureFilterParameters(filter: CIFilter?, filterType: FilterType, intensity: Double) {
        // Set intensity for filters that support it
        if filterType.supportsIntensity {
            setIntensityParameter(filter: filter, filterType: filterType, intensity: intensity)
            
            // Set additional parameters for specific filters
            setAdditionalFilterParameters(filter: filter, filterType: filterType, intensity: intensity)
        }
    }
    
    /// Sets the intensity parameter for the filter
    /// - Parameters:
    ///   - filter: The CIFilter to configure
    ///   - filterType: The type of filter being applied
    ///   - intensity: The intensity value to set
    private func setIntensityParameter(filter: CIFilter?, filterType: FilterType, intensity: Double) {
        filter?.setValue(intensity, forKey: filterType.intensityKey)
    }
    
    /// Sets additional parameters for specific filter types
    /// - Parameters:
    ///   - filter: The CIFilter to configure
    ///   - filterType: The type of filter being applied
    ///   - intensity: The intensity value for additional parameters
    private func setAdditionalFilterParameters(filter: CIFilter?, filterType: FilterType, intensity: Double) {
        switch filterType {
        case .vignette:
            // Vignette needs radius parameter in addition to intensity
            setVignetteParameters(filter: filter, intensity: intensity)
            
        case .bloom, .gloom:
            // Bloom and Gloom use both intensity and radius parameters
            setBloomGloomParameters(filter: filter, intensity: intensity)
            
        default:
            // No additional parameters needed for other filters
            break
        }
    }
    
    /// Configures parameters for vignette filter
    /// - Parameters:
    ///   - filter: The vignette CIFilter
    ///   - intensity: The intensity value for the effect
    private func setVignetteParameters(filter: CIFilter?, intensity: Double) {
        filter?.setValue(intensity * 2, forKey: kCIInputRadiusKey)
    }
    
    /// Configures parameters for bloom and gloom filters
    /// - Parameters:
    ///   - filter: The bloom/gloom CIFilter
    ///   - intensity: The intensity value for the effect
    private func setBloomGloomParameters(filter: CIFilter?, intensity: Double) {
        filter?.setValue(intensity, forKey: kCIInputIntensityKey)
        filter?.setValue(intensity * 10, forKey: kCIInputRadiusKey)
    }
    
    /// Processes the filter output and converts it back to UIImage
    /// - Parameters:
    ///   - filter: The CIFilter that has been configured
    ///   - originalImage: The original UIImage as fallback
    /// - Returns: The filtered UIImage or original if processing fails
    private func processFilterOutput(filter: CIFilter?, originalImage: UIImage) -> UIImage? {
        guard let outputImage = filter?.outputImage,
              let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else {
            // Return original image if filtering fails
            return originalImage
        }
        
        return UIImage(cgImage: cgimg)
    }
}
