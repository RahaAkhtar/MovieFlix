//
//  DependencyConfiguration.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

public struct DependencyConfiguration {
    public static func configure() {
        // Dependencies are configured through the dependency keys in each file
        // No additional configuration needed as they use the default values
    }
    
    public static func configureForTesting() {
        // Dependencies are configured through the dependency keys in each file
        // No additional configuration needed as they use the test values
    }
}

// MARK: - Environment Configuration
public enum Environment {
    case live
    case test
    
    public static var current: Environment {
        #if DEBUG
        return .test
        #else
        return .live
        #endif
    }
}
