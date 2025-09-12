//
//  ImageFilterProcessor.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageFilterProcessor {
    private let context = CIContext()
    
    func applyFilter(to image: UIImage, filterType: FilterType, intensity: Double) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = filterType.ciFilter
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Set intensity for filters that support it
        if filterType.supportsIntensity {
            filter.setValue(intensity, forKey: filterType.intensityKey)
            
            // Set additional parameters for specific filters
            switch filterType {
            case .vignette:
                // Vignette needs radius parameter too
                filter.setValue(intensity * 2, forKey: kCIInputRadiusKey)
            case .bloom, .gloom:
                // Bloom and Gloom use intensity parameter
                filter.setValue(intensity, forKey: kCIInputIntensityKey)
                filter.setValue(intensity * 10, forKey: kCIInputRadiusKey)
            default:
                break
            }
        }
        
        guard let outputImage = filter.outputImage,
              let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgimg)
    }
}

// UIImage extension for scaling
extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
