//
//  RickAndMortyAPI.swift
//  RickAndMortyAPI
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public protocol RickAndMortyAPIProtocol {
    func listCharacters(page: Int?, name: String?, status: Status?, gender: Gender?) async throws -> CharactersPage
    func getCharacter(id: Int) async throws -> CharacterDTO
}

public final class RickAndMortyAPIClient: RickAndMortyAPIProtocol {
    private let builder: RequestBuilder
    private let http: HTTPClientProtocol
    private let decoder: JSONDecoder

    public init(
        baseURL: URL = URL(string: "https://rickandmortyapi.com/api")!,
        http: HTTPClientProtocol = URLSession.shared,
        decoder: JSONDecoder = .init()
    ) {
        self.builder = RequestBuilder(baseURL: baseURL)
        self.http = http
        self.decoder = decoder
    }

    public func listCharacters(
        page: Int? = nil,
        name: String? = nil,
        status: Status? = nil,
        gender: Gender? = nil
    ) async throws -> CharactersPage {

        var items: [URLQueryItem] = []
        if let page { items.append(.init(name: "page", value: String(page))) }
        if let name, !name.isEmpty { items.append(.init(name: "name", value: name)) }
        if let status { items.append(.init(name: "status", value: status.rawValue.lowercased())) }
        if let gender { items.append(.init(name: "gender", value: gender.rawValue.lowercased())) }

        let ep = Endpoint(path: "character", queryItems: items, method: .GET)
        let req = try builder.build(ep)

        let (data, resp) = try await http.send(req)
        guard (200..<300).contains(resp.statusCode) else {
            throw APIError.badStatus(resp.statusCode, data)
        }

        do {
            return try decoder.decode(CharactersPage.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    public func getCharacter(id: Int) async throws -> CharacterDTO {
        let ep = Endpoint(path: "character/\(id)")
        let req = try builder.build(ep)
        let (data, resp) = try await http.send(req)
        guard (200..<300).contains(resp.statusCode) else {
            throw APIError.badStatus(resp.statusCode, data)
        }
        do {
            return try decoder.decode(CharacterDTO.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}


public protocol HTTPClientProtocol {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPClientProtocol {
    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, resp) = try await data(for: request)
            guard let http = resp as? HTTPURLResponse else {
                throw APIError.badStatus(-1, data)
            }
            return (data, http)
        } catch is CancellationError {
            throw URLError(.cancelled)
        } catch {
            throw error
        }
    }
}
