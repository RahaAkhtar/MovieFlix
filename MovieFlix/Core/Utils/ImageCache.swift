//
//  ImageCache.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import UIKit

// Simple in-memory image cache
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insertImage(_ image: UIImage?, forKey key: String) {
        guard let image = image else {
            cache.removeObject(forKey: key as NSString)
            return
        }
        cache.setObject(image, forKey: key as NSString)
    }
}
