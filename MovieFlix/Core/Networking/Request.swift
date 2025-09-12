//
//  Request.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public struct Request<T: Decodable> {
    public let baseURL: URL
    public let path: String
    public let queryItems: [URLQueryItem]
    public let method: String
    public let headers: [String: String]
    public let decoder: JSONDecoder
    
    public init(baseURL: URL,
                path: String,
                queryItems: [URLQueryItem] = [],
                method: String = "GET",
                headers: [String: String] = [:],
                decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
        self.method = method
        self.headers = headers
        self.decoder = decoder
    }
}
