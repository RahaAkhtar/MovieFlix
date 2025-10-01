//
//  ImageLoadingState.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 01/10/2025.
//


// ImageLoadingState.swift
import SwiftUI
import Combine

@Observable
class ImageLoadingState {
    var primaryImageFailed = false
    var fallbackImageFailed = false
    
    func reset() {
        primaryImageFailed = false
        fallbackImageFailed = false
    }
}