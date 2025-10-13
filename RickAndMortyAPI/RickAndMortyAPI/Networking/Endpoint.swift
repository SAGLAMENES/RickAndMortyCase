//
//  Endpoint.swift
//  RickAndMortyAPI
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public struct Endpoint {
    public enum Method: String { case GET, POST, PUT, PATCH, DELETE }
    public var path: String
    public var queryItems: [URLQueryItem] = []
    public var method: Method = .GET

    public init(path: String, queryItems: [URLQueryItem] = [], method: Method = .GET) {
        self.path = path
        self.queryItems = queryItems
        self.method = method
    }
}

public struct RequestBuilder {
    public let baseURL: URL
    public let defaultHeaders: [String: String]

    public init(baseURL: URL, defaultHeaders: [String: String] = ["Accept":"application/json"]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }

    public func build(_ endpoint: Endpoint) throws -> URLRequest {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !endpoint.queryItems.isEmpty { comps.queryItems = endpoint.queryItems }
        guard let url = comps.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method.rawValue
        defaultHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.cachePolicy = .returnCacheDataElseLoad
        return req
    }
}
