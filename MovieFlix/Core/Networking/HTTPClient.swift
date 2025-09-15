//
//  HTTPClient.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation
import Dependencies

public protocol HTTPClient {
    func send<T: Decodable>(_ request: Request<T>) async throws -> T
}

public struct Request<T: Decodable> {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    
    public init(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(Int, String)
    case networkError(String)
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Dependency Key
private enum HTTPClientKey: DependencyKey {
    static let liveValue: HTTPClient = URLSessionHTTPClient()
    static let testValue: HTTPClient = MockHTTPClient()
}

extension DependencyValues {
    public var httpClient: HTTPClient {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
}
