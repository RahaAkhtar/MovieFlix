//
//  URLSessionHTTPClient.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        guard var components = URLComponents(url: request.baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.urlError
        }
        components.queryItems = request.queryItems
        
        guard let url = components.url else { throw NetworkError.urlError }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.urlError }
        guard 200...299 ~= httpResponse.statusCode else { throw NetworkError.httpError(code: httpResponse.statusCode) }
        
        do {
            return try request.decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
