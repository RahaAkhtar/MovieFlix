//
//  URLSessionHTTPClient.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//

import Foundation

//public final class URLSessionHTTPClient: HTTPClient {
//    private let session: URLSession
//    
//    public init(session: URLSession = .shared) {
//        self.session = session
//    }
//    
//    public func send<T: Decodable>(_ request: Request<T>) async throws -> T {
//        var urlRequest = URLRequest(url: request.url)
//        urlRequest.httpMethod = request.method.rawValue
//        urlRequest.httpBody = request.body
//        
//        // Add headers
//        for (key, value) in request.headers {
//            urlRequest.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        do {
//            let (data, response) = try await session.data(for: urlRequest)
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw NetworkError.unknown
//            }
//            
//            guard 200...299 ~= httpResponse.statusCode else {
//                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
//                throw NetworkError.serverError(httpResponse.statusCode, errorMessage)
//            }
//            
//            guard !data.isEmpty else {
//                throw NetworkError.noData
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                let result = try decoder.decode(T.self, from: data)
//                return result
//            } catch {
//                throw NetworkError.decodingError(error.localizedDescription)
//            }
//        } catch let error as NetworkError {
//            throw error
//        } catch {
//            throw NetworkError.networkError(error.localizedDescription)
//        }
//    }
//}

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        requestTimeout: TimeInterval = 15,
        resourceTimeout: TimeInterval = 60,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = requestTimeout
        config.timeoutIntervalForResource = resourceTimeout
        self.session = URLSession(configuration: config)
        self.decoder = decoder
    }

    func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        let urlRequest = request.toURLRequest()
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

        return try decoder.decode(T.self, from: data)
    }
}
