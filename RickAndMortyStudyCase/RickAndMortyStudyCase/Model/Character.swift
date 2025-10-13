//
//  Character.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import Foundation

public struct Character: Identifiable, Equatable {
    public let id: Int
    public let name: String
    public let status: CharacterStatus
    public let gender: CharacterGender
    public let species: String
    public let imageURL: URL?
    public let locationName: String
    public var isFavorite: Bool = false
}

public enum CharacterStatus: Sendable { case alive, dead, unknown }
public enum CharacterGender: Sendable { case male, female, genderless, unknown }
