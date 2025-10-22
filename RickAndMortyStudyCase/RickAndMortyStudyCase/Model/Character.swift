//
//  Character.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import Foundation
import SwiftUI
import RickAndMortyPersistence

public struct Character: Identifiable, Equatable, Hashable {
    public let id: Int
    public let name: String
    public let status: CharacterStatus
    public let gender: CharacterGender
    public let species: String
    public let imageURL: URL?
    public let locationName: String
    public let originName: String
    public let episodeCount: Int
    public var isFavorite: Bool = false
    
    public var asLocal: CharacterLocal {
        CharacterLocal(
            id: Int64(id),
            name: name,
            status: status.label,
            gender: gender.label,
            species: species,
            imageURL: imageURL?.absoluteString ?? "",
            locationName: locationName
        )
    }
}

public enum CharacterStatus: Sendable { 
    case alive, dead, unknown
    
    public var label: String {
        switch self {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }
    
    public var symbolName: String {
        switch self {
        case .alive: return "heart.fill"
        case .dead: return "xmark.octagon.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }
}

public enum CharacterGender: Sendable { 
    case male, female, genderless, unknown
    
    public var label: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        case .unknown: return "Unknown"
        }
    }
}
