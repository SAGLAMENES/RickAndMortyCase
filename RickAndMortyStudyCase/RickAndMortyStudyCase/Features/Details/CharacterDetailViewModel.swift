//
//  CharacterDetailViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import Foundation
import RickAndMortyAPI
import RickAndMortyPersistence

protocol CharacterDetailViewProtocol {
    func toggleFavorite()
}

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: Character
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var relatedByLocation: [CharacterDTO] = []
    @Published private(set) var relatedByEpisode: [CharacterDTO] = []
    @Published private(set) var isLoadingRelated = false

    private let local: CharacterLocalDataSource
    private let api: RickAndMortyAPIProtocol

    init(
        character: Character,
        local: CharacterLocalDataSource = DefaultCharacterLocalDataSource(),
        api: RickAndMortyAPIProtocol = RickAndMortyAPIClient()
    ) {
        self.character = character
        self.local = local
        self.api = api
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
            print("favorite toggle error: \(error)")
        }
    }
    
    func loadRelatedCharacters() {
        isLoadingRelated = true
        Task {
            defer { isLoadingRelated = false }
            async let locationTask = fetchLocationCharacters()
            async let episodeTask = fetchEpisodeCharacters()
            
            let (location, episode) = await (locationTask, episodeTask)
            self.relatedByLocation = location
            self.relatedByEpisode = episode
        }
    }
    
    private func fetchLocationCharacters() async -> [CharacterDTO] {
        do {
            let page = try await api.listCharacters(page: 1, name: nil, status: nil, gender: nil)
            return page.results.filter { 
                $0.location.name == character.locationName && $0.id != character.id 
            }
        } catch {
            return []
        }
    }
    
    private func fetchEpisodeCharacters() async -> [CharacterDTO] {
        do {
            let allCharacters = try await fetchAllCharacters()
            return allCharacters.filter { 
                $0.id != character.id && !$0.episode.isEmpty 
            }.prefix(6).map { $0 }
        } catch {
            return []
        }
    }
    
    private func fetchAllCharacters() async throws -> [CharacterDTO] {
        var allCharacters: [CharacterDTO] = []
        var page = 1
        var hasNextPage = true
        
        while hasNextPage && page <= 3 {
            let result = try await api.listCharacters(page: page, name: nil, status: nil, gender: nil)
            allCharacters.append(contentsOf: result.results)
            hasNextPage = result.info.next != nil
            page += 1
        }
        
        return allCharacters
    }
}
