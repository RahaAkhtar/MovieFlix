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

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}


// Example Request - adapt to your existing type if it already exists
public struct Request<Response: Decodable> {
    public let url: URL
    public var method: String = "GET"
    public var headers: [String: String]? = nil
    public var body: Data? = nil

    public init(
        url: URL,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}


// Create URLRequest from Request
extension Request {
    func toURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        if let headers = headers {
            for (k, v) in headers { urlRequest.setValue(v, forHTTPHeaderField: k) }
        }
        urlRequest.httpBody = body
        return urlRequest
    }
}


public enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(Int, String)
    case networkError(String)
    case timeout
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
        case .timeout:
            return "Timeout error occurred"
        }
    }
}

extension HTTPClient {
    func sendWithRetry<T: Decodable>(
        _ request: Request<T>,
        maxRetries: Int = 3,
        maxElapsedTime: TimeInterval = 30, // cutoff in seconds
        requestTimeout: TimeInterval = 15,
        resourceTimeout: TimeInterval = 60
    ) async throws -> T {
        var attempt = 0
        let startTime = Date()
        var lastError: Error?

        while attempt < maxRetries {
            do {
                var urlRequest = request.toURLRequest()
                urlRequest.timeoutInterval = requestTimeout

                let config = URLSessionConfiguration.default
                config.timeoutIntervalForResource = resourceTimeout
                let session = URLSession(configuration: config)

                let (data, response) = try await session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError(
                        httpResponse.statusCode,
                        HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    )
                }

                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                lastError = error
                attempt += 1

                if !shouldRetry(error) || attempt >= maxRetries {
                    throw error
                }
                if Date().timeIntervalSince(startTime) > maxElapsedTime {
                    throw NetworkError.timeout
                }

                // Exponential backoff with jitter
                let baseDelay = pow(2.0, Double(attempt - 1)) * 0.5
                let jitter = Double.random(in: 0...(baseDelay / 2))
                let delay = baseDelay + jitter
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError ?? NetworkError.unknown
    }

    private func shouldRetry(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .cannotConnectToHost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        return false
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
