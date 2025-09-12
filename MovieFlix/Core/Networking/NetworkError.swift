//
//  NetworkError.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public enum NetworkError: Error {
    case urlError
    case httpError(code: Int)
    case decodingError(Error)
    case unknown(Error)
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.urlError, .urlError):
            return true
        case let (.httpError(code1), .httpError(code2)):
            return code1 == code2
        case (.decodingError, .decodingError):
            // We don’t compare actual Error values
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
