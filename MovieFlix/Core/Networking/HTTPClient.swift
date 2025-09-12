//
//  HTTPClient.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import Foundation

public protocol HTTPClient {
    func send<T: Decodable>(_ request: Request<T>) async throws -> T
}
