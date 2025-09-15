//
//  Untitled.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 15/09/2025.
//
import UIKit
import Foundation

// MARK: - UIImage Extension for Scaling
/// Extension to provide image scaling functionality
// UIImage extension for scaling
extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
