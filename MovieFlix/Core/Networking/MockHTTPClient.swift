//
//  MockHTTPClient.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation

public final class MockHTTPClient: HTTPClient {
    public var responses: [URL: Any] = [:]
    public var errors: [URL: Error] = [:]
    
    public init() {}
    
    public func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        if let error = errors[request.url] {
            throw error
        }
        
        guard let response = responses[request.url] as? T else {
            throw NetworkError.noData
        }
        
        return response
    }
    
    public func setResponse<T: Decodable>(_ response: T, for url: URL) {
        responses[url] = response
    }
    
    public func setError(_ error: Error, for url: URL) {
        errors[url] = error
    }
}
