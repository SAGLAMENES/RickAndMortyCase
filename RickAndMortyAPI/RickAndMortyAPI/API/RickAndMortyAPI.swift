//
//  RickAndMortyAPI.swift
//  RickAndMortyAPI
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public protocol RickAndMortyAPIProtocol{
    func listCharacters(page: Int?, name: String?, status: Status?, gender: Gender?) async throws -> Page<CharacterDTO>
    func getCharacter(id: Int) async throws -> CharacterDTO
    func getLocation(id: Int) async throws -> LocationDTO
    func getEpisode(id: Int) async throws -> EpisodesDTO
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
    
    public func getLocation(id: Int) async throws -> LocationDTO {
           let request = try builder.makeGET(path: "location/\(id)")
        let (data, response) = try await http.send(request)
           try Self.validate(response)
           return try decoder.decode(LocationDTO.self, from: data)
       }

       public func getEpisode(id: Int) async throws -> EpisodesDTO {
           let request = try builder.makeGET(path: "episode/\(id)")
           let (data, response) = try await http.send(request)
           try Self.validate(response)
           return try decoder.decode(EpisodesDTO.self, from: data)
       }
    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.invalidStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }
    public func listCharacters(page: Int?, name: String?, status: Status?, gender: Gender?) async throws -> Page<CharacterDTO>  {

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
            return try decoder.decode(Page.self, from: data)
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
        var lastError: Error?
        
        for attempt in 0..<3 {
            do {
                let (data, resp) = try await data(for: request)
                guard let http = resp as? HTTPURLResponse else {
                    throw APIError.badStatus(-1, data)
                }
                
                if http.statusCode == 403 || http.statusCode == 429 {
                    if attempt < 2 {
                        let delay = UInt64(pow(2.0, Double(attempt)) * 1_000_000_000)
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }
                }
                
                return (data, http)
            } catch is CancellationError {
                throw URLError(.cancelled)
            } catch {
                lastError = error
                if attempt < 2 {
                    let delay = UInt64(pow(2.0, Double(attempt)) * 500_000_000)
                    try? await Task.sleep(nanoseconds: delay)
                    continue
                }
            }
        }
        
        throw lastError ?? URLError(.unknown)
    }
}
extension RequestBuilder {
    func makeGET(path: String, query: [URLQueryItem] = []) throws -> URLRequest {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comps.queryItems = query.isEmpty ? nil : query
        guard let url = comps.url else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.cachePolicy = .returnCacheDataElseLoad
        req.timeoutInterval = 30
        defaultHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        return req
    }
}
