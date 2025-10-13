//
//  FavoritesViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import Foundation
import RickAndMortyPersistence
import RickAndMortyAPI
@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var items: [Character] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let local: CharacterLocalDataSource

    init(local: CharacterLocalDataSource = DefaultCharacterLocalDataSource()) {
        self.local = local
    }

    func load() {
        isLoading = true
        errorMessage = nil
        do {
            let locals = try local.fetchFavorites()
            let mapped = locals.map { $0.toDomain() }
            self.items = mapped.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ character: Character) {
        do {
            try local.removeFavorite(id: Int64(character.id))
            items.removeAll { $0.id == character.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Mapping: CharacterLocal -> Domain Character
import struct Foundation.URL

extension CharacterLocal {
    func toDomain() -> Character {
        Character(
            id: Int(id),
            name: name,
            status: CharacterStatus.from(label: status),
            gender: CharacterGender.from(label: gender),
            species: species,
            imageURL: URL(string: imageURL),
            locationName: locationName
        )
    }
}

extension CharacterStatus {
    static func from(label: String) -> CharacterStatus {
        switch label {
        case "Alive": return .alive
        case "Dead": return .dead
        default: return .unknown
        }
    }
}

extension CharacterGender {
    static func from(label: String) -> CharacterGender {
        switch label {
        case "Male": return .male
        case "Female": return .female
        case "Genderless": return .genderless
        default: return .unknown
        }
    }
}

extension CharacterDTO {
    var asLocal: CharacterLocal {
        CharacterLocal(
            id: Int64(id),
            name: name,
            status: status.rawValue,
            gender: gender.rawValue,
            species: species,
            imageURL: image,
            locationName: location.name
        )
    }
}
