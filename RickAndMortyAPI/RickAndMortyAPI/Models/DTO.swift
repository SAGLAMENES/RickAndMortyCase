//
//  DTO.swift
//  RickAndMortyAPI
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public struct CharactersPage: Decodable {
    public struct Info: Decodable {
            public let count: Int
            public let pages: Int
            public let next: String?
            public let prev: String?
    }
    public let info: Info
    public let results: [CharacterDTO]
}

public struct CharacterDTO: Decodable, Identifiable {
    public let id: Int
    public let name: String
    public let status: Status
    public let species: String
    public let type: String
    public let gender: Gender
    public let origin: Location
    public let location: Location
    public let image: String
    public let episode: [String]
    public let url: String
    public let created: String
}

public struct Location: Decodable {
    public let name: String
    public let url: String
}

public enum Status: String, Decodable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}

public enum Gender: String, Decodable {
    case female = "Female"
    case male = "Male"
    case genderless = "Genderless"
    case unknown = "unknown"
}
