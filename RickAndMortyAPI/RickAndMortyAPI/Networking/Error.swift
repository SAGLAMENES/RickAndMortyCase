//
//  Error.swift
//  RickAndMortyAPI
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int, Data?)
    case decoding(Error)
    case invalidStatusCode(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badStatus(let code, _): return "Bad stat us code: \(code)"
        case .decoding(let err): return "Decoding failed: \(err.localizedDescription)"
        case .invalidStatusCode(let code): return "Invalid status code: \(code)"
        }
    }
}
