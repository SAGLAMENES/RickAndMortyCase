//
//  CharacterDetailViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import Foundation
import RickAndMortyPersistence

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: Character
    @Published private(set) var isFavorite: Bool = false

    private let local: CharacterLocalDataSource

    init(character: Character,
         local: CharacterLocalDataSource = DefaultCharacterLocalDataSource()) {
        self.character = character
        self.local = local
        self.isFavorite = (try? local.isFavorite(id: Int64(character.id))) ?? false
    }

    func toggleFavorite() {
        do {
            let id64 = Int64(character.id)
            if try local.isFavorite(id: id64) {
                try local.removeFavorite(id: id64)
                isFavorite = false
            } else {
                try local.addFavorite(character.asLocal)
                isFavorite = true
            }
        } catch {
            // burada istersen hata UI'ı göster
            print("favorite toggle error: \(error)")
        }
    }
}
extension Character {
    var asLocal: CharacterLocal {
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
